let _refreshPromise = null;

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

    if (res.status === 401) {
        const refreshed = await _ensureRefresh();
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

// 동시에 여러 401이 발생해도 refresh는 한 번만 실행되고, 모든 호출이 같은 Promise를 await한다.
function _ensureRefresh() {
    if (!_refreshPromise) {
        _refreshPromise = _tryRefresh().finally(() => { _refreshPromise = null; });
    }
    return _refreshPromise;
}

async function _tryRefresh() {
    const refreshToken = getRefreshToken();
    if (!refreshToken) return false;
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
    }
}

// JWT payload의 exp를 디코딩해 만료까지 남은 초를 반환한다. 파싱 실패 시 0.
function _getSecondsUntilExpiry(token) {
    try {
        const payload = JSON.parse(atob(token.split('.')[1]));
        return payload.exp - Math.floor(Date.now() / 1000);
    } catch (_) {
        return 0;
    }
}

// 페이지 진입 시 호출. 토큰 없으면 login으로, 만료 60초 이내면 선제 리프레시.
async function requireAuth() {
    const token = getAccessToken();
    if (!token) { window.location.href = 'login.html'; return; }
    if (_getSecondsUntilExpiry(token) < 60) {
        const refreshed = await _ensureRefresh();
        if (!refreshed) {
            clearTokens();
            window.location.href = 'login.html';
        }
    }
}
