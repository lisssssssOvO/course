<template>
    <div class="manager">
        <h2>Категории</h2>

        <div class="add-form">
            <input v-model="newCategory.name" placeholder="Название" />
            <input v-model.number="newCategory.budget" placeholder="Бюджет" type="number" />
            <label>
                <input type="checkbox" v-model="newCategory.isActive" />
                Активна
            </label>
            <button class="btn-success" @click="addCategory">Добавить</button>
        </div>

        <div v-if="loading" class="loading">Загрузка...</div>
        <div v-else-if="categories.length === 0" class="empty">Нет категорий</div>

        <div v-else class="list">
            <div v-for="c in categories" :key="c.id" class="item">
                <div class="info">
                    <span>{{ c.name }}</span>
                    <span class="amount">{{ c.budget }} ₽</span>
                    <span :class="c.isActive ? 'status-active' : 'status-inactive'">
                        {{ c.isActive ? 'Активна' : 'Неактивна' }}
                    </span>
                </div>
                <div class="actions">
                    <button class="btn-warning" @click="startEdit(c)">Редактировать</button>
                    <button class="btn-danger" @click="deleteCategory(c.id)">Удалить</button>
                </div>
            </div>
        </div>

        <div v-if="editing" class="modal-overlay" @click.self="editing = null">
            <div class="modal-content">
                <h3>Редактировать категорию</h3>
                <input v-model="editData.name" placeholder="Название" />
                <input v-model.number="editData.budget" placeholder="Бюджет" type="number" />
                <label>
                    <input type="checkbox" v-model="editData.isActive" />
                    Активна
                </label>
                <div class="modal-actions">
                    <button class="save" @click="updateCategory">Сохранить</button>
                    <button class="cancel" @click="editing = null">Отмена</button>
                </div>
            </div>
        </div>
    </div>
</template>

<script setup>
    import { ref, onMounted } from 'vue'
    import { categoriesApi } from '../api/categories'

    const categories = ref([])
    const loading = ref(false)
    const editing = ref(null)
    const editData = ref({ name: '', budget: 0, isActive: true })
    const newCategory = ref({ name: '', budget: 0, isActive: true })

    const loadCategories = async () => {
        loading.value = true
        try {
            const response = await categoriesApi.getAll()
            categories.value = response.data
        } catch (error) {
            console.error('Ошибка загрузки:', error)
        } finally {
            loading.value = false
        }
    }

    const addCategory = async () => {
        if (!newCategory.value.name) {
            alert('Введите название')
            return
        }
        try {
            await categoriesApi.create(newCategory.value)
            newCategory.value = { name: '', budget: 0, isActive: true }
            await loadCategories()
        } catch (error) {
            console.error('Ошибка создания:', error)
        }
    }

    const startEdit = (category) => {
        editing.value = category.id
        editData.value = { ...category }
    }

    const updateCategory = async () => {
        try {
            await categoriesApi.update(editing.value, editData.value)
            editing.value = null
            await loadCategories()
        } catch (error) {
            console.error('Ошибка обновления:', error)
        }
    }

    const deleteCategory = async (id) => {
        if (!confirm('Удалить категорию?')) return
        try {
            await categoriesApi.delete(id)
            await loadCategories()
        } catch (error) {
            alert('Нельзя удалить категорию, у которой есть статьи')
        }
    }

    onMounted(loadCategories)
</script>

<style scoped>
    @import '../styles/common.css';
    @import '../styles/manager.css';
</style>