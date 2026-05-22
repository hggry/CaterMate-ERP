import { createRouter, createWebHistory, type RouteRecordRaw } from 'vue-router'
import { useAuthStore } from '@/stores/authStore'
import AppLayout from '@/components/layout/AppLayout.vue'
import LoginView from '@/views/LoginView.vue'
import NotFoundView from '@/views/NotFoundView.vue'
import DashboardView from '@/views/DashboardView.vue'
import OrderListView from '@/views/OrderListView.vue'
import OrderDetailView from '@/views/OrderDetailView.vue'
import OrderOverviewView from '@/views/OrderOverviewView.vue'
import OrderQuoteView from '@/views/OrderQuoteView.vue'
import OrderPurchaseListView from '@/views/OrderPurchaseListView.vue'
import OrderInvoiceView from '@/views/OrderInvoiceView.vue'
import MenuItemsView from '@/views/MenuItemsView.vue'
import IngredientsView from '@/views/IngredientsView.vue'
import IncomingInvoiceView from '@/views/IncomingInvoiceView.vue'
const routes: RouteRecordRaw[] = [
  {
    path: '/login',
    name: 'login',
    component: LoginView,
    meta: { public: true },
  },
  {
    path: '/',
    component: AppLayout,
    children: [
      { path: '', redirect: { name: 'dashboard' } },
      { path: 'dashboard', name: 'dashboard', component: DashboardView },
      { path: 'orders', name: 'orders', component: OrderListView },
      {
        path: 'orders/:id',
        component: OrderDetailView,
        props: true,
        children: [
          { path: '', name: 'order-detail', component: OrderOverviewView },
          { path: 'quote', name: 'order-quote', component: OrderQuoteView },
          { path: 'purchase-list', name: 'order-purchase-list', component: OrderPurchaseListView },
          { path: 'invoice', name: 'order-invoice', component: OrderInvoiceView },
        ],
      },
      { path: 'menu-items', name: 'menu-items', component: MenuItemsView },
      { path: 'ingredients', name: 'ingredients', component: IngredientsView },
      { path: 'incoming-invoices', name: 'incoming-invoices', component: IncomingInvoiceView },
      { path: ':pathMatch(.*)*', name: 'not-found', component: NotFoundView },
    ],
  },
]

const router = createRouter({
  history: createWebHistory(),
  routes,
})

router.beforeEach((to) => {
  const auth = useAuthStore()
  if (to.meta.public) {
    return to.name === 'login' && auth.isAuthenticated ? { name: 'dashboard' } : true
  }
  return auth.isAuthenticated ? true : { name: 'login' }
})

export default router
