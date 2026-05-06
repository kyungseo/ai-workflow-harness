const API = `${GATEWAY}/api/v1/todos`;

let currentPage = 0;
const PAGE_SIZE = 10;

async function loadTodos(page = 0) {
    currentPage = page;
    const res = await fetchWithAuth(`${API}?page=${page}&size=${PAGE_SIZE}`);
    if (!res) return;
    if (!res.ok) { showError('할 일 목록을 불러오지 못했습니다.'); return; }
    const body = await res.json();
    renderTodos(body.data);
}

function renderTodos(page) {
    const list = document.getElementById('todo-list');
    list.innerHTML = '';

    if (!page || page.content.length === 0) {
        list.innerHTML = '<li class="list-group-item text-muted">할 일이 없습니다.</li>';
    } else {
        page.content.forEach(todo => {
            const li = document.createElement('li');
            li.className = 'list-group-item d-flex justify-content-between align-items-center';
            li.innerHTML = `
                <div class="d-flex align-items-center gap-2">
                    <input type="checkbox" class="form-check-input" ${todo.completed ? 'checked' : ''}
                           onchange="toggleComplete(${todo.id}, this)">
                    <span class="${todo.completed ? 'text-decoration-line-through text-muted' : ''}">${escHtml(todo.title)}</span>
                </div>
                <button class="btn btn-sm btn-outline-danger" onclick="deleteTodo(${todo.id})">삭제</button>
            `;
            list.appendChild(li);
        });
    }

    renderPagination(page);
}

function renderPagination(page) {
    const el = document.getElementById('pagination');
    el.innerHTML = '';
    if (!page || page.totalPages <= 1) return;

    const ul = document.createElement('ul');
    ul.className = 'pagination pagination-sm mb-0';

    const addItem = (label, pageNum, disabled, active) => {
        const li = document.createElement('li');
        li.className = `page-item${disabled ? ' disabled' : ''}${active ? ' active' : ''}`;
        li.innerHTML = `<a class="page-link" href="#" onclick="event.preventDefault();${disabled ? '' : `loadTodos(${pageNum})`}">${label}</a>`;
        ul.appendChild(li);
    };

    addItem('이전', page.number - 1, page.number === 0, false);
    for (let i = 0; i < page.totalPages; i++) {
        addItem(i + 1, i, false, i === page.number);
    }
    addItem('다음', page.number + 1, page.number >= page.totalPages - 1, false);
    el.appendChild(ul);
}

async function createTodo() {
    const title = document.getElementById('todo-title').value.trim();
    const desc  = document.getElementById('todo-desc').value.trim();
    if (!title) { showError('제목을 입력하세요.'); return; }

    const res = await fetchWithAuth(API, {
        method: 'POST',
        body: JSON.stringify({ title, description: desc }),
    });
    if (!res) return;
    if (!res.ok) { const b = await res.json(); showError(b.message || '생성 실패'); return; }

    document.getElementById('todo-title').value = '';
    document.getElementById('todo-desc').value = '';
    hideError();
    await loadTodos(0);
}

async function toggleComplete(id, checkbox) {
    const res = await fetchWithAuth(`${API}/${id}/complete`, { method: 'PATCH' });
    if (!res || !res.ok) { checkbox.checked = !checkbox.checked; showError('상태 변경 실패'); }
    else await loadTodos(currentPage);
}

async function deleteTodo(id) {
    if (!confirm('삭제하시겠습니까?')) return;
    const res = await fetchWithAuth(`${API}/${id}`, { method: 'DELETE' });
    if (!res || !res.ok) { showError('삭제 실패'); return; }
    await loadTodos(currentPage);
}

function showError(msg) {
    const el = document.getElementById('error-msg');
    el.textContent = msg;
    el.classList.remove('d-none');
}

function hideError() {
    document.getElementById('error-msg').classList.add('d-none');
}

function escHtml(str) {
    return str.replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;');
}
