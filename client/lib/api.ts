const API_BASE = process.env.NEXT_PUBLIC_API_URL ?? "/api";

export async function apiFetch(path: string, init?: RequestInit) {
    // path like "/users/health" -> request goes to "/api/users/health"
    return fetch(`${API_BASE}${path}`, init);
}