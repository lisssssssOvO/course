import apiClient from './client'

export const transactionsApi = {
    getAll: (params) => apiClient.get('/transactions', { params }),
    getById: (id) => apiClient.get(`/transactions/${id}`),
    create: (data) => apiClient.post('/transactions', data),
    update: (id, data) => apiClient.put(`/transactions/${id}`, data),
    delete: (id) => apiClient.delete(`/transactions/${id}`),
    getStats: (date) => apiClient.get('/transactions/stats', { params: { date } })
}