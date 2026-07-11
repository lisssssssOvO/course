<template>
    <div class="manager">
        <h2>Транзакции</h2>

        <div class="add-form">
            <input type="date" v-model="newTransaction.date" />
            <input v-model.number="newTransaction.amount"
                   placeholder="Сумма"
                   type="number"
                   step="0.01"
                   min="0.01" />
            <input v-model="newTransaction.comment" placeholder="Комментарий" />

            <select v-model="newTransaction.expenseItemId">
                <option v-for="item in activeItems" :key="item.id" :value="item.id">
                    {{ item.name }} ({{ item.categoryName }})
                </option>
            </select>

            <button class="btn-success" @click="addTransaction">Добавить</button>
        </div>

        <div class="filters">
            <input type="date" v-model="filters.day" @change="loadTransactions" placeholder="День" />
            <input type="month" v-model="filters.month" @change="loadTransactions" placeholder="Месяц" />
            <button @click="clearFilters">Очистить фильтры</button>
        </div>

        <div v-if="loading" class="loading">Загрузка...</div>
        <div v-else-if="transactions.length === 0" class="empty">Нет транзакций</div>

        <div v-else class="list">
            <div v-for="t in transactions" :key="t.id" class="item">
                <div class="info">
                    <span class="date">{{ t.date }}</span>
                    <span class="tag-category">{{ t.categoryName }}</span>
                    <span>{{ t.expenseItemName }}</span>
                    <span class="comment">{{ t.comment || '' }}</span>
                    <span class="amount">{{ t.amount.toFixed(2) }} ₽</span>
                </div>
                <div class="actions">
                    <button class="btn-warning" @click="startEdit(t)">Редактировать</button>
                    <button class="btn-danger" @click="deleteTransaction(t.id)">Удалить</button>
                </div>
            </div>
        </div>

        <div v-if="editing" class="modal-overlay" @click.self="editing = null">
            <div class="modal-content">
                <h3>Редактировать транзакцию</h3>

                <label>Дата</label>
                <input type="date" v-model="editData.date" />

                <label>Сумма</label>
                <input v-model.number="editData.amount"
                       type="number"
                       step="0.01"
                       min="0.01" />

                <label>Комментарий</label>
                <input v-model="editData.comment" placeholder="Комментарий" />

                <label>Статья расхода</label>
                <select v-model="editData.expenseItemId" :disabled="isCurrentItemInactive">
                    <option v-for="item in allItems"
                            :key="item.id"
                            :value="item.id"
                            :disabled="!item.isActive && item.id !== editData.originalExpenseItemId">
                        {{ item.name }} ({{ item.categoryName }})
                        {{ !item.isActive ? '(Неактивна)' : '' }}
                    </option>
                </select>

                <div v-if="isCurrentItemInactive" class="warning">
                    Текущая статья неактивна. Изменение статьи запрещено!
                </div>

                <div class="modal-actions">
                    <button class="save" @click="updateTransaction">Сохранить</button>
                    <button class="cancel" @click="editing = null">Отмена</button>
                </div>
            </div>
        </div>
    </div>
</template>

<script setup>
    import { ref, onMounted, computed } from 'vue'
    import { transactionsApi } from '../api/transactions'
    import { expenseItemsApi } from '../api/expenseItems'

    const transactions = ref([])
    const items = ref([])
    const loading = ref(false)
    const editing = ref(null)
    const editData = ref({
        date: '',
        amount: 0,
        comment: '',
        expenseItemId: null,
        originalExpenseItemId: null
    })
    const filters = ref({ day: '', month: '' })
    const newTransaction = ref({
        date: new Date().toISOString().split('T')[0],
        amount: 0,
        comment: '',
        expenseItemId: null
    })

    const activeItems = computed(() => {
        return items.value.filter(i => i.isActive === true)
    })

    const allItems = computed(() => {
        return items.value
    })

    const isCurrentItemInactive = computed(() => {
        if (!editing.value) return false

        const currentItem = items.value.find(i => i.id === editData.value.originalExpenseItemId)
        if (currentItem && !currentItem.isActive) {
            return true
        }
        return false
    })

    const loadItems = async () => {
        try {
            const response = await expenseItemsApi.getAll()
            items.value = response.data

            if (!newTransaction.value.expenseItemId && activeItems.value.length) {
                newTransaction.value.expenseItemId = activeItems.value[0].id
            }
        } catch (error) {
            console.error('Ошибка загрузки статей:', error)
        }
    }

    const loadTransactions = async () => {
        loading.value = true
        try {
            const params = {}
            if (filters.value.day) params.day = filters.value.day
            if (filters.value.month) params.month = filters.value.month
            const response = await transactionsApi.getAll(params)
            transactions.value = response.data
        } catch (error) {
            console.error('Ошибка загрузки транзакций:', error)
        } finally {
            loading.value = false
        }
    }

    const addTransaction = async () => {
        if (newTransaction.value.amount <= 0) {
            alert('Сумма должна быть положительным числом!')
            return
        }

        if (!newTransaction.value.amount) {
            alert('Введите сумму')
            return
        }

        if (!newTransaction.value.expenseItemId) {
            alert('Выберите статью расхода')
            return
        }

        try {
            await transactionsApi.create(newTransaction.value)
            newTransaction.value.amount = 0
            newTransaction.value.comment = ''
            await loadItems()
            await loadTransactions()
        } catch (error) {
            alert(error.response?.data || 'Ошибка создания транзакции')
        }
    }

    const startEdit = (transaction) => {
        editing.value = transaction.id
        editData.value = {
            date: transaction.date,
            amount: transaction.amount,
            comment: transaction.comment || '',
            expenseItemId: transaction.expenseItemId,
            originalExpenseItemId: transaction.expenseItemId
        }
    }

    const updateTransaction = async () => {
        if (editData.value.amount <= 0) {
            alert('Сумма должна быть положительным числом!')
            return
        }

        if (isCurrentItemInactive.value) {
            alert('Нельзя изменить статью, так как она стала неактивной')
            return
        }

        try {
            await transactionsApi.update(editing.value, {
                date: editData.value.date,
                amount: editData.value.amount,
                comment: editData.value.comment,
                expenseItemId: editData.value.expenseItemId
            })
            editing.value = null
            await loadTransactions()
        } catch (error) {
            alert(error.response?.data || 'Ошибка обновления транзакции')
        }
    }

    const deleteTransaction = async (id) => {
        if (!confirm('Удалить транзакцию?')) return
        try {
            await transactionsApi.delete(id)
            await loadTransactions()
        } catch (error) {
            console.error('Ошибка удаления:', error)
        }
    }

    const clearFilters = () => {
        filters.value = { day: '', month: '' }
        loadTransactions()
    }

    onMounted(async () => {
        await loadItems()
        await loadTransactions()
    })
</script>

<style scoped>
    @import '../styles/common.css';
    @import '../styles/manager.css';

    .warning {
        background: #fff3cd;
        color: #856404;
        padding: 10px;
        border-radius: 6px;
        margin: 8px 0;
        border-left: 4px solid #ffc107;
        font-size: 14px;
    }

    .modal-content label {
        display: block;
        font-weight: 500;
        margin-top: 8px;
        font-size: 14px;
        color: #2d3436;
    }

    .modal-content select:disabled {
        background: #e9ecef;
        cursor: not-allowed;
        opacity: 0.7;
    }

    .modal-content select option:disabled {
        color: #999;
        font-style: italic;
    }
</style>