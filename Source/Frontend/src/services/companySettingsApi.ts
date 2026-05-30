import http from './http'
import type { CompanySettingsDto, UpdateCompanySettingsRequest } from '@/types/companySettings'

export const companySettingsApi = {
  get: (): Promise<CompanySettingsDto> =>
    http.get<CompanySettingsDto>('/company-settings').then((r) => r.data),

  update: (payload: UpdateCompanySettingsRequest): Promise<CompanySettingsDto> =>
    http.put<CompanySettingsDto>('/company-settings', payload).then((r) => r.data),

  uploadLogo: (file: File): Promise<CompanySettingsDto> => {
    const form = new FormData()
    form.append('file', file)
    return http
      .post<CompanySettingsDto>('/company-settings/logo', form, {
        headers: { 'Content-Type': 'multipart/form-data' },
      })
      .then((r) => r.data)
  },

  // Returns the raw URL to use in <img src="...">.
  logoUrl: (): string => '/api/company-settings/logo',
}
