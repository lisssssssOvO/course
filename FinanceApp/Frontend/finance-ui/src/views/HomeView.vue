<template>
    <div class="container">
        <h1>Учет личных финансов</h1>

        <div class="tabs">
            <button v-for="tab in tabs"
                    :key="tab.key"
                    @click="activeTab = tab.key"
                    :class="{ active: activeTab === tab.key }">
                {{ tab.label }}
            </button>
        </div>

        <DailyStats v-if="activeTab === 'stats'" />
        <TransactionManager v-if="activeTab === 'transactions'" />
        <CategoryManager v-if="activeTab === 'categories'" />
        <ExpenseItemManager v-if="activeTab === 'items'" />
    </div>
</template>

<script setup>
    import { ref } from 'vue'
    import DailyStats from '../components/DailyStats.vue'
    import TransactionManager from '../components/TransactionManager.vue'
    import CategoryManager from '../components/CategoryManager.vue'
    import ExpenseItemManager from '../components/ExpenseItemManager.vue'

    const tabs = [
        { key: 'stats', label: 'Статистика' },
        { key: 'transactions', label: 'Транзакции' },
        { key: 'categories', label: 'Категории' },
        { key: 'items', label: 'Статьи' }
    ]

    const activeTab = ref('stats')
</script>

<style scoped>
    @import '../styles/common.css';
    @import '../styles/tabs.css';
</style>