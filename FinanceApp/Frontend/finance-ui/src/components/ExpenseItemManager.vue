<template>
    <div class="manager">
        <h2>Статьи расходов</h2>

        <div class="add-form">
            <input v-model="newItem.name" placeholder="Название" />
            <select v-model="newItem.categoryId">
                <option v-for="c in activeCategories" :key="c.id" :value="c.id">
                    {{ c.name }}
                </option>
            </select>
            <label>
                <input type="checkbox" v-model="newItem.isActive" />
                Активна
            </label>
            <button class="btn-success" @click="addItem">Добавить</button>
        </div>

        <div v-if="loading" class="loading">Загрузка...</div>
        <div v-else-if="items.length === 0" class="empty">Нет статей</div>

        <div v-else class="list">
            <div v-for="item in items" :key="item.id" class="item">
                <div class="info">
                    <span>{{ item.name }}</span>
                    <span class="tag-category">{{ item.categoryName }}</span>
                    <span :class="item.isActive ? 'status-active' : 'status-inactive'">
                        {{ item.isActive ? 'Активна' : 'Неактивна' }}
                    </span>
                </div>
                <div class="actions">
                    <button class="btn-warning" @click="startEdit(item)">Редактировать</button>
                    <button class="btn-danger" @click="deleteItem(item.id)">Удалить</button>
                </div>
            </div>
        </div>

        <div v-if="editing" class="modal-overlay" @click.self="editing = null">
            <div class="modal-content">
                <h3>Редактировать статью</h3>
                <input v-model="editData.name" placeholder="Название" />

                <select v-model="editData.categoryId" :disabled="isCurrentCategoryInactive">
                    <option v-for="c in categories"
                            :key="c.id"
                            :value="c.id"
                            :disabled="!c.isActive && c.id !== editData.originalCategoryId">
                        {{ c.name }}
                        {{ !c.isActive ? '(Неактивна)' : '' }}
                    </option>
                </select>

                <div v-if="isCurrentCategoryInactive" class="warning">
                    Текущая категория неактивна. Изменение категории запрещено!
                </div>

                <label>
                    <input type="checkbox" v-model="editData.isActive" />
                    Активна
                </label>
                <div class="modal-actions">
                    <button class="save" @click="updateItem">Сохранить</button>
                    <button class="cancel" @click="editing = null">Отмена</button>
                </div>
            </div>
        </div>
    </div>
</template>

<script setup>
    import { ref, onMounted, computed } from 'vue'
    import { expenseItemsApi } from '../api/expenseItems'
    import { categoriesApi } from '../api/categories'

    const items = ref([])
    const categories = ref([])
    const loading = ref(false)
    const editing = ref(null)
    const editData = ref({
        name: '',
        categoryId: null,
        isActive: true,
        originalCategoryId: null
    })
    const newItem = ref({ name: '', categoryId: null, isActive: true })

    const activeCategories = computed(() => {
        return categories.value.filter(c => c.isActive === true)
    })

    const isCurrentCategoryInactive = computed(() => {
        if (!editing.value) return false

        const currentCategory = categories.value.find(c => c.id === editData.value.originalCategoryId)
        if (currentCategory && !currentCategory.isActive) {
            return true 
        }
        return false
    })

    const loadData = async () => {
        loading.value = true
        try {
            const [itemsRes, catsRes] = await Promise.all([
                expenseItemsApi.getAll(),
                categoriesApi.getAll()
            ])
            items.value = itemsRes.data
            categories.value = catsRes.data

            if (!newItem.value.categoryId && activeCategories.value.length) {
                newItem.value.categoryId = activeCategories.value[0].id
            }
        } catch (error) {
            console.error('Ошибка загрузки:', error)
        } finally {
            loading.value = false
        }
    }

    const addItem = async () => {
        if (!newItem.value.name || !newItem.value.categoryId) {
            alert('Заполните все поля')
            return
        }
        try {
            await expenseItemsApi.create(newItem.value)
            newItem.value = { name: '', categoryId: activeCategories.value[0]?.id || null, isActive: true }
            await loadData()
        } catch (error) {
            console.error('Ошибка создания:', error)
        }
    }

    const startEdit = (item) => {
        editing.value = item.id
        editData.value = {
            ...item,
            originalCategoryId: item.categoryId
        }
    }

    const updateItem = async () => {
        if (isCurrentCategoryInactive.value) {
            alert('Нельзя изменить категорию, так как она стала неактивной')
            return
        }

        try {
            await expenseItemsApi.update(editing.value, editData.value)
            editing.value = null
            await loadData()
        } catch (error) {
            console.error('Ошибка обновления:', error)
        }
    }

    const deleteItem = async (id) => {
        if (!confirm('Удалить статью?')) return
        try {
            await expenseItemsApi.delete(id)
            await loadData()
        } catch (error) {
            alert('Нельзя удалить статью, у которой есть транзакции')
        }
    }

    onMounted(loadData)
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