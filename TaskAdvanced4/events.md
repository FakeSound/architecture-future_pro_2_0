# Каталог доменных событий — Будущее 2.0

## Медицинский домен (Clinical)

### patient.registered
| Поле | Значение |
|------|----------|
| **Источник** | Clinical Services API |
| **Семантика** | Новый пациент прошёл регистрацию и верификацию личности |
| **Подписчики** | Fintech (открыть счёт), Operations (зарегистрировать в клинике), Data Platform |

**Контракт:**
```json
{
  "patient_id": "uuid",
  "registered_at": "ISO 8601",
  "clinic_id": "uuid"
}
```

---

### appointment.created
| Поле | Значение |
|------|----------|
| **Источник** | Clinical Services API |
| **Семантика** | Записан приём пациента к врачу |
| **Подписчики** | Operations (бронирование кабинета), Data Platform |

**Контракт:**
```json
{
  "appointment_id": "uuid",
  "patient_id": "uuid",
  "doctor_id": "uuid",
  "clinic_id": "uuid",
  "scheduled_at": "ISO 8601"
}
```

---

### appointment.completed
| Поле | Значение |
|------|----------|
| **Источник** | Clinical Services API |
| **Семантика** | Приём завершён, пациент обслужен |
| **Подписчики** | Fintech (инициировать оплату), Pharma (контекст рецепта), Data Platform |

**Контракт:**
```json
{
  "appointment_id": "uuid",
  "patient_id": "uuid",
  "completed_at": "ISO 8601",
  "billing_code": "string"
}
```

---

### diagnosis.added
| Поле | Значение |
|------|----------|
| **Источник** | Clinical Services API |
| **Семантика** | Врач добавил диагноз в медицинскую карту |
| **Подписчики** | AI Services (запустить анализ), Data Platform |

**Контракт:**
```json
{
  "record_id": "uuid",
  "patient_id": "uuid",
  "icd10_code": "string",
  "diagnosed_at": "ISO 8601"
}
```

---

### study.ordered
| Поле | Значение |
|------|----------|
| **Источник** | Clinical Services API |
| **Семантика** | Врач назначил медицинское исследование |
| **Подписчики** | AI Services (подготовить диагностику), Data Platform |

**Контракт:**
```json
{
  "study_id": "uuid",
  "patient_id": "uuid",
  "study_type": "string",
  "ordered_at": "ISO 8601"
}
```

---

### study.completed
| Поле | Значение |
|------|----------|
| **Источник** | Clinical Services API |
| **Семантика** | Результаты исследования получены и сохранены |
| **Подписчики** | Data Platform |

**Контракт:**
```json
{
  "study_id": "uuid",
  "patient_id": "uuid",
  "result_ref": "string",
  "completed_at": "ISO 8601"
}
```

---

## Финтех-домен (Fintech)

### account.opened
| Поле | Значение |
|------|----------|
| **Источник** | Fintech Services API |
| **Семантика** | Открыт новый финансовый счёт для пациента |
| **Подписчики** | Data Platform |

**Контракт:**
```json
{
  "account_id": "uuid",
  "owner_id": "uuid",
  "currency": "string",
  "opened_at": "ISO 8601"
}
```

---

### payment.completed
| Поле | Значение |
|------|----------|
| **Источник** | Fintech Services API |
| **Семантика** | Платёж успешно проведён |
| **Подписчики** | Clinical (разблокировать услугу), Data Platform |

**Контракт:**
```json
{
  "payment_id": "uuid",
  "account_id": "uuid",
  "amount": "decimal",
  "appointment_id": "uuid",
  "completed_at": "ISO 8601"
}
```

---

### payment.failed
| Поле | Значение |
|------|----------|
| **Источник** | Fintech Services API |
| **Семантика** | Попытка проведения платежа завершилась ошибкой |
| **Подписчики** | Clinical (уведомить оператора), Data Platform |

**Контракт:**
```json
{
  "payment_id": "uuid",
  "account_id": "uuid",
  "reason": "string",
  "failed_at": "ISO 8601"
}
```

---

### credit.approved
| Поле | Значение |
|------|----------|
| **Источник** | Fintech Services API |
| **Семантика** | Кредитная заявка одобрена |
| **Подписчики** | Clinical (разрешить кредитные приёмы), Data Platform |

**Контракт:**
```json
{
  "contract_id": "uuid",
  "account_id": "uuid",
  "principal": "decimal",
  "approved_at": "ISO 8601"
}
```

---

## Операционный домен (Operations)

### clinic.activated
| Поле | Значение |
|------|----------|
| **Источник** | Operations Services API |
| **Семантика** | Клиника открыта и готова к работе |
| **Подписчики** | Clinical (доступна для расписания), Data Platform |

**Контракт:**
```json
{
  "clinic_id": "uuid",
  "name": "string",
  "address": "string",
  "activated_at": "ISO 8601"
}
```

---

### staff.assigned
| Поле | Значение |
|------|----------|
| **Источник** | Operations Services API |
| **Семантика** | Сотрудник назначен в клинику |
| **Подписчики** | Clinical (врач доступен для расписания), Data Platform |

**Контракт:**
```json
{
  "staff_id": "uuid",
  "clinic_id": "uuid",
  "role": "string",
  "assigned_at": "ISO 8601"
}
```

---

### staff.unassigned
| Поле | Значение |
|------|----------|
| **Источник** | Operations Services API |
| **Семантика** | Сотрудник снят с назначения в клинику |
| **Подписчики** | Clinical (врач недоступен), Data Platform |

**Контракт:**
```json
{
  "staff_id": "uuid",
  "clinic_id": "uuid",
  "unassigned_at": "ISO 8601"
}
```

---

### inventory.threshold.reached
| Поле | Значение |
|------|----------|
| **Источник** | Operations Services API |
| **Семантика** | Остаток товара в клинике опустился ниже минимального порога |
| **Подписчики** | Data Platform, Back-office |

**Контракт:**
```json
{
  "item_id": "uuid",
  "clinic_id": "uuid",
  "current_quantity": "int",
  "threshold": "int",
  "occurred_at": "ISO 8601"
}
```

---

## Фармацевтический домен (Pharma)

### prescription.issued
| Поле | Значение |
|------|----------|
| **Источник** | Pharma Services API |
| **Семантика** | Рецепт оформлен и передан пациенту после завершения приёма |
| **Триггер** | `appointment.completed` из Clinical |
| **Подписчики** | Data Platform |

**Контракт:**
```json
{
  "prescription_id": "uuid",
  "patient_id": "uuid",
  "appointment_id": "uuid",
  "drug_code": "string",
  "dosage": "string",
  "valid_until": "ISO 8601",
  "issued_at": "ISO 8601"
}
```

---

### supply.received
| Поле | Значение |
|------|----------|
| **Источник** | Pharma Services API |
| **Семантика** | Партия препаратов поступила на склад аптечной сети |
| **Подписчики** | Data Platform |

**Контракт:**
```json
{
  "supply_id": "uuid",
  "medication_id": "uuid",
  "clinic_id": "uuid",
  "quantity": "int",
  "batch_number": "string",
  "received_at": "ISO 8601"
}
```

---

### stock.low
| Поле | Значение |
|------|----------|
| **Источник** | Pharma Services API |
| **Семантика** | Остаток препарата опустился ниже минимального порога |
| **Подписчики** | Operations (инициировать закупку), Data Platform |

**Контракт:**
```json
{
  "medication_id": "uuid",
  "clinic_id": "uuid",
  "current_quantity": "int",
  "threshold": "int",
  "occurred_at": "ISO 8601"
}
```

---

## ИИ-сервисы (AI Diagnostics)

### diagnosis.completed
| Поле | Значение |
|------|----------|
| **Источник** | AI Services |
| **Семантика** | Модель завершила анализ и сформировала диагностическое заключение |
| **Подписчики** | Clinical (прикрепить к медкарте), Data Platform |

**Контракт:**
```json
{
  "job_id": "uuid",
  "study_id": "uuid",
  "model_version": "string",
  "findings": "string",
  "confidence_score": "float",
  "completed_at": "ISO 8601"
}
```

---

### diagnosis.failed
| Поле | Значение |
|------|----------|
| **Источник** | AI Services |
| **Семантика** | Анализ завершился ошибкой (недостаточное качество снимка, сбой модели) |
| **Подписчики** | Clinical (уведомить врача), Data Platform |

**Контракт:**
```json
{
  "job_id": "uuid",
  "study_id": "uuid",
  "reason": "string",
  "failed_at": "ISO 8601"
}
```
