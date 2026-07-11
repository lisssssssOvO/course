import apiClient from './client'

export const expenseItemsApi = {
    getAll: () => apiClient.get('/expenseitems'),
    getById: (id) => apiClient.get(`/expenseitems/${id}`),
    create: (data) => apiClient.post('/expenseitems', data),
    update: (id, data) => apiClient.put(`/expenseitems/${id}`, data),
    delete: (id) => apiClient.delete(`/expenseitems/${id}`)
}