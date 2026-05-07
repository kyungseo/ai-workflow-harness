const GATEWAY = 'http://localhost:8090';
const KEYS = { ACCESS: 'accessToken', REFRESH: 'refreshToken', DEVICE: 'deviceId', USER: 'currentUser' };

function getOrCreateDeviceId() {
    let id = localStorage.getItem(KEYS.DEVICE);
    if (!id) {
        id = crypto.randomUUID();
        localStorage.setItem(KEYS.DEVICE, id);
    }
    return id;
}

function getAccessToken()  { return localStorage.getItem(KEYS.ACCESS); }
function getRefreshToken() { return localStorage.getItem(KEYS.REFRESH); }

function setTokens(accessToken, refreshToken) {
    localStorage.setItem(KEYS.ACCESS, accessToken);
    localStorage.setItem(KEYS.REFRESH, refreshToken);
}

function clearTokens() {
    localStorage.removeItem(KEYS.ACCESS);
    localStorage.removeItem(KEYS.REFRESH);
    localStorage.removeItem(KEYS.USER);
}

function setCurrentUser(user) { localStorage.setItem(KEYS.USER, JSON.stringify(user)); }
function getCurrentUser()     { const u = localStorage.getItem(KEYS.USER); return u ? JSON.parse(u) : null; }

async function login(username, password) {
    const res = await fetch(`${GATEWAY}/api/v1/auth/login`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ username, password, deviceId: getOrCreateDeviceId() }),
    });
    const body = await res.json();
    if (!res.ok) throw new Error(body.message || '로그인에 실패했습니다.');
    setTokens(body.data.accessToken, body.data.refreshToken);
    return body.data;
}

async function logout() {
    const token = getAccessToken();
    if (token) {
        try {
            await fetch(`${GATEWAY}/api/v1/auth/logout`, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                    'Authorization': `Bearer ${token}`,
                },
                body: JSON.stringify({ deviceId: getOrCreateDeviceId() }),
            });
        } catch (_) { /* 서버 응답 실패 시에도 로컬 토큰 삭제 진행 */ }
    }
    clearTokens();
    window.location.href = 'login.html';
}

