CREATE TABLE "БОЛЬНИЦА"
(
    КОД_БОЛЬНИЦЫ SERIAL PRIMARY KEY UNIQUE,
    НАИМЕНОВАНИЕ VARCHAR NOT NULL,
    АДРЕС VARCHAR,
    ЧИСЛО_КОЕК SERIAL
);
CREATE TABLE "ПАЛАТА"
(
    КОД_БОЛЬНИЦЫ SERIAL,
    НОМЕР_ПАЛАТЫ SERIAL,
    НАЗВАНИЕ VARCHAR,
    ЧИСЛО_КОЕК SERIAL,

    PRIMARY KEY (КОД_БОЛЬНИЦЫ, НОМЕР_ПАЛАТЫ),

    FOREIGN KEY (КОД_БОЛЬНИЦЫ) REFERENCES "БОЛЬНИЦА" (КОД_БОЛЬНИЦЫ)
);
CREATE TABLE "ПЕРСОНАЛ"
(
    КОД_БОЛЬНИЦЫ SERIAL,
    НОМЕР_ПАЛАТЫ SERIAL NOT NULL,
    ФАМИЛИЯ VARCHAR,
    ДОЛЖНОСТЬ VARCHAR,
    CHECK (ДОЛЖНОСТЬ = 'МЕДСЕСТРА' OR ДОЛЖНОСТЬ = 'НЯНЯ' OR ДОЛЖНОСТЬ = 'СИДЕЛКА' OR ДОЛЖНОСТЬ = 'САНИТАР'),
    СМЕНА VARCHAR,
    CHECK (СМЕНА = 'УТРЕННЯЯ' OR СМЕНА = 'ВЕЧЕРНЯЯ' OR СМЕНА = 'НОЧНАЯ'),
    ЗАРПЛАТА SERIAL,
    CHECK (ЗАРПЛАТА >= 1000 AND ЗАРПЛАТА <=10000),

    PRIMARY KEY (КОД_БОЛЬНИЦЫ, НОМЕР_ПАЛАТЫ),

    FOREIGN KEY (КОД_БОЛЬНИЦЫ) REFERENCES "БОЛЬНИЦА" (КОД_БОЛЬНИЦЫ)
);
CREATE TABLE "ВРАЧ"
(
    КОД_ВРАЧА SERIAL NOT NULL UNIQUE,
    КОД_БОЛЬНИЦЫ SERIAL,
    ФАМИЛИЯ VARCHAR,
    СПЕЦИАЛЬНОСТЬ VARCHAR,

    PRIMARY KEY (КОД_ВРАЧА),

    FOREIGN KEY (КОД_БОЛЬНИЦЫ) REFERENCES "БОЛЬНИЦА" (КОД_БОЛЬНИЦЫ)
);
CREATE TABLE "ПАЦИЕНТ"
(
    РЕГИСТРАЦИОННЫЙ_НОМЕР SERIAL NOT NULL UNIQUE,
    ФАМИЛИЯ VARCHAR,
    АДРЕС VARCHAR,
    ДАТА_РОЖДЕНИЯ DATE,
    CHECK (ДАТА_РОЖДЕНИЯ > '1900-01-01'),
    ПОЛ VARCHAR,
    CHECK (ПОЛ = 'МУЖСКОЙ' OR ПОЛ = 'ЖЕНСКИЙ'),
    НОМЕР_МЕДИЦИНСКОГО_ПОЛИСА SERIAL,

    PRIMARY KEY (РЕГИСТРАЦИОННЫЙ_НОМЕР)
);
CREATE TABLE "ДИАГНОЗ"
(
    РЕГИСТРАЦИОННЫЙ_НОМЕР SERIAL NOT NULL,
    ТИП_ДИАГНОЗА VARCHAR,
    ОСЛОЖНЕНИЯ VARCHAR,
    ПРЕДУПРЕЖДАЮЩАЯ_ИНФОРМАЦИЯ VARCHAR,

    FOREIGN KEY (РЕГИСТРАЦИОННЫЙ_НОМЕР) REFERENCES "ПАЦИЕНТ" (РЕГИСТРАЦИОННЫЙ_НОМЕР)
);
CREATE TABLE "ЛАБОРАТОРИЯ"
(
    КОД_ЛАБОРАТОРИИ SERIAL NOT NULL UNIQUE,
    НАЗВАНИЕ VARCHAR,
    АДРЕС VARCHAR,

    PRIMARY KEY (КОД_ЛАБОРАТОРИИ)
);
CREATE TABLE "АНАЛИЗ"
(
    РЕГИСТРАЦИОННЫЙ_НОМЕР SERIAL NOT NULL,
    КОД_ЛАБОРАТОРИИ SERIAL NOT NULL,
    ТИП_АНАЛИЗА VARCHAR,
    НАЗНАЧЕННАЯ_ДАТА DATE,
    НАЗНАЧЕННОЕ_ВРЕМЯ TIMESTAMP,
    НОМЕР_НАПРАВЛЕНИЯ SERIAL,
    СОСТОЯНИЕ VARCHAR,

    FOREIGN KEY (РЕГИСТРАЦИОННЫЙ_НОМЕР) REFERENCES "ПАЦИЕНТ" (РЕГИСТРАЦИОННЫЙ_НОМЕР),
    FOREIGN KEY (КОД_ЛАБОРАТОРИИ) REFERENCES "ЛАБОРАТОРИЯ" (КОД_ЛАБОРАТОРИИ)
);
CREATE TABLE "БОЛЬНИЦА ЛАБОРАТОРИИ"
(
    КОД_БОЛЬНИЦЫ SERIAL NOT NULL,
    КОД_ЛАБОРАТОРИИ SERIAL NOT NULL,

    PRIMARY KEY (КОД_БОЛЬНИЦЫ, КОД_ЛАБОРАТОРИИ),

    FOREIGN KEY (КОД_БОЛЬНИЦЫ) REFERENCES "БОЛЬНИЦА" (КОД_БОЛЬНИЦЫ),
    FOREIGN KEY (КОД_ЛАБОРАТОРИИ) REFERENCES "ЛАБОРАТОРИЯ" (КОД_ЛАБОРАТОРИИ)
);
CREATE TABLE "ВРАЧ-ПАЦИЕНТ"
(
    КОД_ВРАЧА SERIAL NOT NULL,
    РЕГИСТРАЦИОННЫЙ_НОМЕР SERIAL NOT NULL,

    PRIMARY KEY (КОД_ВРАЧА, РЕГИСТРАЦИОННЫЙ_НОМЕР),

    FOREIGN KEY (КОД_ВРАЧА) REFERENCES "ВРАЧ" (КОД_ВРАЧА),
    FOREIGN KEY (РЕГИСТРАЦИОННЫЙ_НОМЕР) REFERENCES "ПАЦИЕНТ" (РЕГИСТРАЦИОННЫЙ_НОМЕР)
);
CREATE TABLE "РАЗМЕЩЕНИЕ"
(
    КОД_БОЛЬНИЦЫ SERIAL NOT NULL,
    НОМЕР_ПАЛАТЫ SERIAL,
    НОМЕР_КОЙКИ SERIAL,
    РЕГИСТРАЦИОННЫЙ_НОМЕР SERIAL NOT NULL,

    PRIMARY KEY (КОД_БОЛЬНИЦЫ, НОМЕР_ПАЛАТЫ, НОМЕР_КОЙКИ),

    FOREIGN KEY (КОД_БОЛЬНИЦЫ, НОМЕР_ПАЛАТЫ) REFERENCES "ПАЛАТА" (КОД_БОЛЬНИЦЫ, НОМЕР_ПАЛАТЫ),
    FOREIGN KEY (РЕГИСТРАЦИОННЫЙ_НОМЕР) REFERENCES "ПАЦИЕНТ" (РЕГИСТРАЦИОННЫЙ_НОМЕР)
);
CREATE TABLE "ТЕЛЕФОН БОЛЬНИЦЫ"
(
    КОД_БОЛЬНИЦЫ SERIAL NOT NULL,
    ТЕЛЕФОН VARCHAR,

    PRIMARY KEY (ТЕЛЕФОН, КОД_БОЛЬНИЦЫ),

    FOREIGN KEY (КОД_БОЛЬНИЦЫ) REFERENCES "БОЛЬНИЦА" (КОД_БОЛЬНИЦЫ)
);
CREATE TABLE "ТЕЛЕФОН ЛАБОРАТОРИИ"
(
    КОД_ЛАБОРАТОРИИ SERIAL NOT NULL,
    ТЕЛЕФОН VARCHAR,

    PRIMARY KEY (ТЕЛЕФОН, КОД_ЛАБОРАТОРИИ),

    FOREIGN KEY (КОД_ЛАБОРАТОРИИ) REFERENCES "ЛАБОРАТОРИЯ" (КОД_ЛАБОРАТОРИИ)
);