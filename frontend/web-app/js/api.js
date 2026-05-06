let _refreshing = false;

async function fetchWithAuth(url, options = {}) {
    const token = getAccessToken();
    const opts = {
        ...options,
        headers: {
            'Content-Type': 'application/json',
            ...(options.headers || {}),
            ...(token ? { 'Authorization': `Bearer ${token}` } : {}),
        },
    };

    let res = await fetch(url, opts);

    if (res.status === 401 && !_refreshing) {
        const refreshed = await _tryRefresh();
        if (refreshed) {
            opts.headers['Authorization'] = `Bearer ${getAccessToken()}`;
            res = await fetch(url, opts);
        } else {
            clearTokens();
            window.location.href = 'login.html';
            return;
        }
    }

    return res;
}

async function _tryRefresh() {
    const refreshToken = getRefreshToken();
    if (!refreshToken) return false;
    _refreshing = true;
    try {
        const res = await fetch(`${GATEWAY}/api/v1/auth/refresh`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ refreshToken, deviceId: getOrCreateDeviceId() }),
        });
        if (!res.ok) return false;
        const body = await res.json();
        setTokens(body.data.accessToken, body.data.refreshToken);
        return true;
    } catch (_) {
        return false;
    } finally {
        _refreshing = false;
    }
}
