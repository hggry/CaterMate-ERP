export interface CompanySettingsDto {
  companyName: string
  street: string | null
  postalCode: string | null
  city: string | null
  country: string | null
  phone: string | null
  email: string | null
  website: string | null
  vatId: string | null
  taxNumber: string | null
  iban: string | null
  bic: string | null
  bankName: string | null
  commercialRegNo: string | null
  commercialCourt: string | null
  hasLogo: boolean
}

export interface UpdateCompanySettingsRequest {
  companyName: string
  street?: string
  postalCode?: string
  city?: string
  country?: string
  phone?: string
  email?: string
  website?: string
  vatId?: string
  taxNumber?: string
  iban?: string
  bic?: string
  bankName?: string
  commercialRegNo?: string
  commercialCourt?: string
}
