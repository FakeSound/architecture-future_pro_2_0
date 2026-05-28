# Агрегаты доменов — Будущее 2.0

## Медицинский контекст (Clinical)

### Patient
| Поле                | Тип    | Описание                     |
|---------------------|--------|------------------------------|
| `patient_id`        | UUID   | Корень агрегата              |
| `full_name`         | string | ФИО                          |
| `birth_date`        | date   | Дата рождения                |
| `status`            | enum   | ACTIVE / ARCHIVED            |
| `identity_verified` | bool   | Признак верификации личности |

**Инварианты:**
- Пациент не может быть записан на приём без `identity_verified = true`
- Персональные данные хранятся только в Clinical DB, в события попадает только `patient_id`

---

### Appointment
| Поле             | Тип      | Описание                          |
|------------------|----------|-----------------------------------|
| `appointment_id` | UUID     | Корень агрегата                   |
| `patient_id`     | UUID     | Ссылка на Patient                 |
| `doctor_id`      | UUID     | Ссылка на StaffMember             |
| `clinic_id`      | UUID     | Ссылка на Clinic                  |
| `scheduled_at`   | datetime | Время приёма                      |
| `status`         | enum     | SCHEDULED / COMPLETED / CANCELLED |

**Инварианты:**
- Один врач не может иметь два приёма в одно время (no double-booking)
- Отмена возможна только в статусе SCHEDULED
- Перевод в COMPLETED инициирует публикацию `appointment.completed`

---

### MedicalRecord
| Поле         | Тип      | Описание                      |
|--------------|----------|-------------------------------|
| `record_id`  | UUID     | Корень агрегата               |
| `patient_id` | UUID     | Ссылка на Patient             |
| `entries`    | list     | Диагнозы, назначения, заметки |
| `created_at` | datetime | Дата создания                 |

**Инварианты:**
- Добавлять записи может только врач, проводивший приём
- Запись нельзя удалить — только аннулировать с комментарием
- Диагноз должен содержать код МКБ-10

---

### Study
| Поле         | Тип    | Описание                             |
|--------------|--------|--------------------------------------|
| `study_id`   | UUID   | Корень агрегата                      |
| `patient_id` | UUID   | Ссылка на Patient                    |
| `type`       | enum   | MRI / CT / LAB / ECHO / ...          |
| `status`     | enum   | ORDERED / IN_PROGRESS / COMPLETED    |
| `result_ref` | string | Ссылка на файл в PACS/Object Storage |

**Инварианты:**
- Результаты исследований хранятся в отдельном хранилище (StudiesStorage), в БД — только метаданные и ссылка
- Переход в COMPLETED публикует `study.completed`

---

## Финтех-контекст (Fintech)

### Account
| Поле           | Тип     | Описание                     |
|----------------|---------|------------------------------|
| `account_id`   | UUID    | Корень агрегата              |
| `owner_id`     | UUID    | `patient_id` из Clinical     |
| `balance`      | decimal | Текущий баланс               |
| `credit_limit` | decimal | Кредитный лимит (0 если нет) |
| `currency`     | string  | Валюта счёта                 |
| `status`       | enum    | ACTIVE / FROZEN / CLOSED     |

**Инварианты:**
- `balance + credit_limit >= 0` всегда
- Закрытый счёт нельзя пополнить или списать

---

### CreditContract
| Поле            | Тип      | Описание                             |
|-----------------|----------|--------------------------------------|
| `contract_id`   | UUID     | Корень агрегата                      |
| `account_id`    | UUID     | Привязан к Account                   |
| `principal`     | decimal  | Сумма кредита                        |
| `interest_rate` | decimal  | Процентная ставка                    |
| `status`        | enum     | PENDING / APPROVED / ACTIVE / CLOSED |
| `approved_at`   | datetime | Дата одобрения                       |

**Инварианты:**
- Одобрение публикует `credit.approved`
- Нельзя открыть два активных кредита на один Account

---

### Payment
| Поле              | Тип     | Описание                       |
|-------------------|---------|--------------------------------|
| `payment_id`      | UUID    | Корень агрегата                |
| `idempotency_key` | UUID    | Ключ идемпотентности           |
| `from_account_id` | UUID    | Счёт списания                  |
| `to_account_id`   | UUID    | Счёт зачисления                |
| `amount`          | decimal | Сумма                          |
| `status`          | enum    | INITIATED / COMPLETED / FAILED |

**Инварианты:**
- Повторный запрос с тем же `idempotency_key` не создаёт новый платёж
- `amount > 0` всегда

---

## Операционный контекст (Operations)

### Clinic
| Поле        | Тип    | Описание                          |
|-------------|--------|-----------------------------------|
| `clinic_id` | UUID   | Корень агрегата                   |
| `name`      | string | Название клиники                  |
| `address`   | string | Адрес                             |
| `capacity`  | int    | Максимальное число приёмов в день |
| `status`    | enum   | ACTIVE / SUSPENDED / CLOSED       |

**Инварианты:**
- Приём может быть создан только в клинике со статусом ACTIVE
- Активация публикует `clinic.activated`

---

### StaffMember
| Поле             | Тип    | Описание                   |
|------------------|--------|----------------------------|
| `staff_id`       | UUID   | Корень агрегата            |
| `clinic_id`      | UUID   | Текущая клиника            |
| `role`           | enum   | DOCTOR / NURSE / ADMIN     |
| `specialization` | string | Специализация (для врачей) |
| `schedule`       | list   | Рабочее расписание         |

**Инварианты:**
- Сотрудник может быть назначен только в клинику со статусом ACTIVE
- Назначение/снятие публикует `staff.assigned` / `staff.unassigned`

---

### InventoryItem
| Поле        | Тип    | Описание          |
|-------------|--------|-------------------|
| `item_id`   | UUID   | Корень агрегата   |
| `clinic_id` | UUID   | Клиника           |
| `name`      | string | Наименование      |
| `quantity`  | int    | Текущий остаток   |
| `threshold` | int    | Минимальный порог |

**Инварианты:**
- `quantity >= 0`
- При `quantity <= threshold` публикуется `inventory.threshold.reached`

---

## Фармацевтический контекст (Pharma)

### Medication
| Поле           | Тип    | Описание                                  |
|----------------|--------|-------------------------------------------|
| `medication_id`| UUID   | Корень агрегата                           |
| `drug_code`    | string | Код препарата (АТХ или внутренний реестр) |
| `name`         | string | Наименование                              |
| `dosage_form`  | enum   | TABLET / CAPSULE / INJECTION / ...        |
| `category`     | enum   | OTC / PRESCRIPTION / CONTROLLED          |
| `is_available` | bool   | Доступен ли к выдаче                      |

**Инварианты:**
- Препараты категории PRESCRIPTION выдаются только при наличии активного `prescription_id`
- Препараты категории CONTROLLED требуют дополнительной авторизации

---

### Prescription
| Поле              | Тип      | Описание                                  |
|-------------------|----------|-------------------------------------------|
| `prescription_id` | UUID     | Корень агрегата                           |
| `patient_id`      | UUID     | Ссылка на Patient (из Clinical)           |
| `appointment_id`  | UUID     | Визит, по итогам которого выписан рецепт  |
| `drug_code`       | string   | Код препарата                             |
| `dosage`          | string   | Дозировка и схема приёма                  |
| `status`          | enum     | ISSUED / DISPENSED / EXPIRED / CANCELLED  |
| `valid_until`     | date     | Срок действия рецепта                     |
| `issued_at`       | datetime | Дата оформления                           |

**Инварианты:**
- Prescription создаётся только по факту `appointment.completed` из Clinical
- Статус нельзя вернуть из DISPENSED или EXPIRED
- Переход в ISSUED публикует `prescription.issued`

---

### Supply
| Поле           | Тип      | Описание                        |
|----------------|----------|---------------------------------|
| `supply_id`    | UUID     | Корень агрегата                 |
| `medication_id`| UUID     | Ссылка на Medication            |
| `clinic_id`    | UUID     | Клиника-получатель              |
| `quantity`     | int      | Поступившее количество          |
| `threshold`    | int      | Минимальный порог для `stock.low`|
| `batch_number` | string   | Номер партии поставщика         |
| `received_at`  | datetime | Дата поступления                |

**Инварианты:**
- `quantity > 0` при создании
- После приёмки Supply обновляет остаток Medication в клинике
- Если обновлённый остаток `<= threshold` — публикуется `stock.low`

---

## ИИ-контекст (AI Diagnostics)

### DiagnosticJob
| Поле            | Тип    | Описание                              |
|-----------------|--------|---------------------------------------|
| `job_id`        | UUID   | Корень агрегата                       |
| `study_id`      | UUID   | Ссылка на Study (из Clinical)         |
| `patient_ref`   | UUID   | Обезличенный идентификатор            |
| `model_version` | string | Версия ML-модели                      |
| `status`        | enum   | QUEUED / RUNNING / COMPLETED / FAILED |
| `result`        | object | Заключение, confidence score          |

**Инварианты:**
- Персональные данные пациента не попадают в DiagnosticJob — только обезличенный `patient_ref`
- Завершение публикует `diagnosis.completed` или `diagnosis.failed`
- Ссылка на снимок передаётся через `study_id`, не хранится в агрегате напрямую
