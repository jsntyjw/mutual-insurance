import { createRouter, createWebHistory } from 'vue-router'

// 路由组件的懒加载
const HR = () => import('../view/HR.vue')
const Main = () => import('../view/Main.vue')

const Login = () => import('../view/Login.vue')

// 路由定义
const routes = [
    { path: '/main', component: Main },
    { path: '/', component: Login },
    { path: '/hr', component: HR }
]

// 创建 router 实例
const router = createRouter({
    history: createWebHistory(),
    routes,
})

export default router
