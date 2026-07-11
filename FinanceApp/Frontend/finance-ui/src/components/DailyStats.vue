<template>
    <div class="stats-card" :class="statusClass">
        <div class="stats-header">
            <h3>Дневная статистика</h3>
            <input type="date" v-model="selectedDate" @change="fetchStats" />
        </div>

        <div class="stats-body">
            <div class="total-amount">
                <span class="label">Сумма трат:</span>
                <span class="amount">{{ formattedTotal }} ₽</span>
            </div>

            <div class="status-message">
                <span class="status-icon" :class="status.toLowerCase()"></span>
                <span>{{ message }}</span>
            </div>
        </div>
    </div>
</template>

<script setup>
    import { ref, computed, onMounted } from 'vue'
    import { transactionsApi } from '../api/transactions'

    const selectedDate = ref(new Date().toISOString().split('T')[0])
    const total = ref(0)
    const message = ref('Загрузка...')
    const status = ref('')

    const statusClass = computed(() => {
        return {
            'stats-green': status.value === 'Green',
            'stats-yellow': status.value === 'Yellow',
            'stats-red': status.value === 'Red',
            'stats-default': !status.value
        }
    })

    const formattedTotal = computed(() => {
        return total.value.toFixed(2)
    })

    const fetchStats = async () => {
        try {
            const response = await transactionsApi.getStats(selectedDate.value)
            total.value = response.data.totalAmount
            message.value = response.data.message
            status.value = response.data.status
        } catch (error) {
            console.error('Ошибка загрузки статистики:', error)
            message.value = 'Ошибка загрузки'
        }
    }

    onMounted(() => {
        fetchStats()
    })
</script>

<style scoped>
    @import '../styles/stats.css';
</style>