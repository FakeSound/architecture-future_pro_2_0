# Стратегический роадмап Data Mesh — Будущее 2.0

## Ключевые роли

| Роль                   | Ответственность                                                                                                  |
|------------------------|------------------------------------------------------------------------------------------------------------------|
| **Data Product Owner** | Владелец data product в домене: качество данных, SLA, документация в DataCatalog. Назначается по одному на домен |
| **Data Engineer**      | Построение и поддержка ингestion-пайплайнов, трансформаций, Lakehouse. Команда платформы                         |
| **Platform Engineer**  | Kafka, Flink, Kubernetes, CI/CD инфраструктура. Команда платформы                                                |
| **BI-аналитик**        | Построение отчётов и дашбордов в Power BI и Superset поверх data products                                        |
| **Domain Developer**   | Разработчики доменных сервисов: добавляют публикацию событий, поддерживают Schema Registry                       |
| **Security & Compliance Officer** | Контроль доступа, классификация данных (PII/PHI), compliance-аудит при подключении каждого домена и при выходе в новые регионы |

---

## Фаза 1: Пилот (мес. 0–6)

**Бизнес-цель:** снизить время подготовки аналитических отчётов, заложить фундамент платформы.

| #  | Активность                                                                           | Роль                              | Домен      | Срок     |
|----|--------------------------------------------------------------------------------------|-----------------------------------|------------|----------|
| 1  | Аудит Legacy DWH: документирование хранимых процедур, ETL-логики и источников данных | Data Engineer                     | Платформа  | мес. 1–2 |
| 2  | Найм и онбординг первой команды: 2 Data Engineer + 1 Platform Engineer               | —                                 | Платформа  | мес. 1–2 |
| 3  | Развёртывание Kafka + Schema Registry в Yandex Cloud                                 | Platform Engineer                 | Платформа  | мес. 1–2 |
| 4  | Настройка базового CI/CD (Terraform + GitHub Actions)                                | Platform Engineer                 | Платформа  | мес. 1–3 |
| 5  | Baseline IAM: настройка Keycloak, ролевые политики для первых доменов                | Security & Compliance Officer     | Платформа  | мес. 1–3 |
| 6  | Clinical domain: публикация первых событий (patient.registered, appointment.created) | Domain Developer                  | Clinical   | мес. 2–4 |
| 7  | Назначение первого Data Product Owner (Clinical)                                     | —                                 | Clinical   | мес. 2   |
| 8  | Классификация данных Clinical в DataHub: разметка PII/PHI-полей                      | Security & Compliance Officer     | Clinical   | мес. 3–4 |
| 9  | Запуск Kafka Connect + Debezium: CDC из Clinical DB в Raw Zone Lakehouse             | Data Engineer                     | Clinical   | мес. 3–5 |
| 10 | Первый data product: **Patient Flow Analytics** (загрузка клиник, динамика приёмов)  | Data Engineer + DPO               | Clinical   | мес. 3–6 |
| 11 | DataHub: первые записи в каталоге (Clinical domain, схемы событий)                   | Data Engineer                     | Платформа  | мес. 5–6 |
| 12 | Пилот Superset: доступ для 5 BI-аналитиков к первому data product                    | BI-аналитик                       | Платформа  | мес. 5–6 |
| 13 | Подключение Power BI к Data Lakehouse вместо Legacy DWH (Clinical data)              | BI-аналитик                       | Clinical   | мес. 5–6 |

**Ключевые результаты:**
- ✓ Первый data product в продакшне
- ✓ Команда платформы сформирована
- ✓ Power BI работает с новыми данными (Clinical)

---

## Фаза 2: Масштабирование (мес. 6–18)

**Бизнес-цель:** перевести все домены на событийную архитектуру, вывести Legacy ESB, запустить self-service аналитику для всей компании.

| #  | Активность                                                                         | Роль                          | Домен                  | Срок       |
|----|------------------------------------------------------------------------------------|-------------------------------|------------------------|------------|
| 1  | Fintech domain: подключение к Kafka, первые события                                | Domain Developer              | Fintech                | мес. 6–9   |
| 2  | Назначение Data Product Owner (Fintech)                                            | —                             | Fintech                | мес. 7     |
| 3  | Security review Fintech: аудит финансовых данных, политики OPA                     | Security & Compliance Officer | Fintech                | мес. 7–8   |
| 4  | Operations domain: подключение к Kafka                                             | Domain Developer              | Operations             | мес. 7–9   |
| 5  | Назначение Data Product Owner (Operations)                                         | —                             | Operations             | мес. 8     |
| 6  | Pharma domain: подключение к Kafka, публикация событий                             | Domain Developer              | Pharma                 | мес. 8–10  |
| 7  | Назначение Data Product Owner (Pharma)                                             | —                             | Pharma                 | мес. 9     |
| 8  | Security review Pharma: классификация рецептурных данных, политики доступа         | Security & Compliance Officer | Pharma                 | мес. 9–10  |
| 9  | CDC для Fintech DB, Operations DB и Pharma DB                                      | Data Engineer                 | Fintech / Ops / Pharma | мес. 7–10  |
| 10 | Запуск Apache Flink: потоковые витрины для Fintech (real-time платёжная аналитика) | Data Engineer                 | Fintech                | мес. 8–11  |
| 11 | Fintech data products: кредитная аналитика, платёжная аналитика                    | Data Engineer + DPO           | Fintech                | мес. 9–13  |
| 12 | Operations data products: загрузка клиник, персонал, инвентарь                     | Data Engineer + DPO           | Operations             | мес. 9–12  |
| 13 | Pharma data products: аналитика рецептов, остатков, поставок                       | Data Engineer + DPO           | Pharma                 | мес. 10–14 |
| 14 | Audit log для всех доступов к data products через DataAccess                       | Security & Compliance Officer | Платформа              | мес. 11–12 |
| 15 | DataHub: все домены в каталоге, data lineage настроен                              | Data Engineer                 | Платформа              | мес. 10–12 |
| 16 | Superset: полный запуск self-service портала для всех BI-аналитиков                | BI-аналитик                   | Платформа              | мес. 11–13 |
| 17 | Power BI: переключение всех существующих отчётов на Lakehouse                      | BI-аналитик                   | Платформа              | мес. 10–14 |
| 18 | Вывод Legacy ESB (Apache Camel): прекращение всех маршрутов                        | Platform Engineer             | Платформа              | мес. 16–18 |

**Ключевые результаты:**
- ✓ Все домены публикуют события в Kafka
- ✓ Self-service портал открыт для всех аналитиков
- ✓ Power BI полностью переведён на новые data products
- ✓ Legacy ESB выведен из эксплуатации

---

## Фаза 3: Зрелость и расширение (мес. 18–36)

**Бизнес-цель:** вывести Legacy DWH, обеспечить data quality SLA, подготовить платформу к выходу в новые регионы.

| #  | Активность                                                                         | Роль                              | Домен       | Срок       |
|----|------------------------------------------------------------------------------------|-----------------------------------|-------------|------------|
| 1  | Миграция исторических данных: Legacy DWH → Data Lakehouse (полная)                 | Data Engineer                     | Платформа   | мес. 18–22 |
| 2  | Вывод Legacy DWH (SQL Server 2008)                                                 | Platform Engineer                 | Платформа   | мес. 22–24 |
| 3  | Data quality SLA: метрики свежести, полноты и корректности для всех data products  | Data Engineer + DPO               | Все домены  | мес. 19–22 |
| 4  | Back-office: управленческая аналитика по всем доменам (cross-domain data products) | Data Engineer                     | Все домены  | мес. 20–24 |
| 5  | AI Services: масштабирование диагностики на потоке событий                         | Domain Developer                  | AI          | мес. 20–26 |
| 6  | Юридический аудит требований data residency для целевых регионов                   | Security & Compliance Officer     | Платформа   | мес. 22–26 |
| 7  | Проектирование multi-region data residency (архитектура + изоляция хранилищ)       | Platform Engineer                 | Платформа   | мес. 24–28 |
| 8  | Onboarding первого нового региона на платформу                                     | Data Engineer + Platform Engineer | Платформа   | мес. 28–34 |
| 9  | Compliance-сертификация нового региона (медицинские и финансовые данные)           | Security & Compliance Officer     | Платформа   | мес. 30–34 |
| 10 | Federated governance: автономные домены, централизованные стандарты качества       | Data Product Owner (все)          | Все домены  | мес. 24–36 |

**Ключевые результаты:**
- ✓ Legacy DWH выведен, миграция данных завершена
- ✓ Все data products имеют измеримые SLA
- ✓ Первый новый регион на платформе
- ✓ Data Mesh полностью операционен

---

## Привязка к бизнес-целям

| Фаза   | Бизнес-результат                                                                        |
|--------|-----------------------------------------------------------------------------------------|
| Фаза 1 | Аналитики получают актуальные данные. Время подготовки отчёта: дни → часы               |
| Фаза 2 | Real-time финтех-продукты. Кредитный скоринг и платёжная аналитика онлайн               |
| Фаза 3 | Выход в новые регионы. AI-диагностика как коммерческий сервис. Полная автономия доменов |
