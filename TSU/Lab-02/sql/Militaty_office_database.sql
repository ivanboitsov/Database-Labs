CREATE TABLE Военкомат
(
    Код_военкомата SERIAL UNIQUE,
    Адрес VARCHAR NOT NULL,
    Номер_телефона VARCHAR,

    PRIMARY KEY (Код_военкомата)
);
CREATE TABLE Персонал
(
    Код_сотрудника SERIAL UNIQUE,
    Код_военкомата SERIAL,
    Фамилия VARCHAR NOT NULL,
    Имя VARCHAR NOT NULL,
    Отчество VARCHAR NOT NULL,
    Дата_рождения DATE,
    CHECK (Дата_рождения > '1900-01-01'),
    Должность_сотрудника VARCHAR NOT NULL,
    CHECK (Должность_сотрудника = 'Начальник военкомата'
        OR Должность_сотрудника = 'Заместитель начальника военкомата'
        OR Должность_сотрудника = 'Военный комиссар'
        OR Должность_сотрудника = 'Специалист по работе с призывниками'
        OR Должность_сотрудника = 'Архивариус'),
    Адрес_проживания VARCHAR,
    Номер_телефона VARCHAR,

    PRIMARY KEY (Код_военкомата, Код_сотрудника),

    FOREIGN KEY (Код_военкомата) REFERENCES Военкомат (Код_военкомата)
);

CREATE TABLE Гражданин
(
    Код_гражданина SERIAL UNIQUE,
    Фамилия VARCHAR NOT NULL,
    Имя VARCHAR NOT NULL,
    Отчество VARCHAR NOT NULL,
    Пол VARCHAR,
    CHECK (Пол = 'Мужской' OR Пол = 'Женский'),
    Дата_рождения DATE NOT NULL,
    CHECK (Дата_рождения > '1900-01-01'),
    Серия_паспорта VARCHAR,
    Номер_паспорта VARCHAR,
    Прописка VARCHAR,
    Адрес_проживания VARCHAR,
    Номер_телефона VARCHAR,

    PRIMARY KEY (Код_гражданина)
);
CREATE TABLE Медкомиссия
(
    Код_медкомиссии SERIAL UNIQUE,
    Код_военкомата SERIAL,
    Дата_приёма DATE NOT NULL,

    PRIMARY KEY (Код_военкомата, Код_медкомиссии),

    FOREIGN KEY (Код_военкомата) REFERENCES Военкомат (Код_военкомата)
);
CREATE TABLE Врач
(
    Код_врача SERIAL UNIQUE,
    Фамилия VARCHAR NOT NULL,
    Имя VARCHAR NOT NULL,
    Отчество VARCHAR NOT NULL,
    Должность_врача VARCHAR NOT NULL,
    CHECK (Должность_врача = 'Окулист' OR Должность_врача = 'Терапевт' OR Должность_врача = 'Хирург'
        OR Должность_врача = 'Стоматолог' OR Должность_врача = 'Психиатр' OR Должность_врача = 'Невропатолог'
        OR Должность_врача = 'Оториноларинголог'),

    PRIMARY KEY (Код_врача)

);
CREATE TABLE "Заключение врача"
(
    Код_заключения SERIAL UNIQUE,
    Код_врача SERIAL,
    Код_гражданина SERIAL,
    Результат VARCHAR NOT NULL,
    CHECK (Результат = 'Годен'
        OR Результат = 'Ограниченно годен'
        OR Результат = 'Временно не годен'
        OR Результат = 'Не годен'
        OR Результат = 'Дополнительное обследование'),

    PRIMARY KEY (Код_гражданина, Код_врача, Код_заключения),

    FOREIGN KEY (Код_врача) REFERENCES Врач (Код_врача),
    FOREIGN KEY (Код_гражданина) REFERENCES Гражданин (Код_гражданина)
);
CREATE TABLE Категория
(
    Код_категории SERIAL UNIQUE,
    Код_гражданина SERIAL,
    Код_сотрудника SERIAL,
    Тип VARCHAR NOT NULL,
    CHECK (Тип = 'А'
        OR Тип = 'Б'
        OR Тип = 'Б-1'
        OR Тип = 'Б-2'
        OR Тип = 'Д'
        OR Тип = 'Запас'),

    PRIMARY KEY (Код_гражданина, Код_категории),

    FOREIGN KEY (Код_сотрудника) REFERENCES Персонал (Код_сотрудника),
    FOREIGN KEY (Код_гражданина) REFERENCES Гражданин  (Код_гражданина)
);
CREATE TABLE "Род войск"
(
    Код_войска SERIAL UNIQUE,
    Наименование VARCHAR,
    CHECK (Наименование = 'Сухопутные войска'
        OR Наименование = 'Воздушно-космические силы'
        OR Наименование = 'Военно-Морской флот'
        OR Наименование = 'Ракетные войска стратегического назначения'
        OR Наименование = 'Воздушно-десантные войска'),

    PRIMARY KEY (Код_войска)

);
CREATE TABLE "Воинская часть"
(
    Код_части SERIAL UNIQUE,
    Код_войска SERIAL,
    Наименование_части VARCHAR NOT NULL,
    Фамилия_командира VARCHAR,
    Имя_командира VARCHAR,

    PRIMARY KEY (Код_войска, Код_части),

    FOREIGN KEY (Код_войска) REFERENCES "Род войск" (Код_войска)
);
CREATE TABLE "Приказ на отправку"
(
    Код_приказа SERIAL UNIQUE,
    Код_военкомата SERIAL,
    Код_части SERIAL,
    Название VARCHAR NOT NULL,
    Дата DATE NOT NULL,

    PRIMARY KEY (Код_военкомата, Код_приказа),

    FOREIGN KEY (Код_военкомата) REFERENCES Военкомат (Код_военкомата),
    FOREIGN KEY (Код_части) REFERENCES "Воинская часть" (Код_части)
);
CREATE TABLE "Медкомиссия-Врач"
(
    Код_медкомиссии SERIAL,
    Код_врача SERIAL,

    PRIMARY KEY (Код_медкомиссии, Код_врача),

    FOREIGN KEY (Код_медкомиссии) REFERENCES Медкомиссия (Код_медкомиссии),
    FOREIGN KEY (Код_врача) REFERENCES Врач (Код_врача)
);
CREATE TABLE "Персонал-Приказы"
(
    Код_сотрудника SERIAL,
    Код_приказа SERIAL,

    PRIMARY KEY (Код_приказа, Код_сотрудника),

    FOREIGN KEY (Код_сотрудника) REFERENCES Персонал (Код_сотрудника),
    FOREIGN KEY (Код_приказа) REFERENCES "Приказ на отправку" (Код_приказа)
);
CREATE TABLE "Гражданин-приказы"
(
    Код_гражданина SERIAL,
    Код_приказа SERIAL,
    Дата_приказа DATE NOT NULL,

    PRIMARY KEY (Код_гражданина, Код_приказа),

    FOREIGN KEY (Код_гражданина) REFERENCES "Гражданин" ("Код_гражданина"),
    FOREIGN KEY (Код_приказа) REFERENCES "Приказ на отправку" (Код_приказа)
);
CREATE TABLE "Медкомиссия-Заключение врача"
(
    Код_медкомиссии SERIAL,
    Код_заключения SERIAL,
    Дата_заключения SERIAL NOT NULL,

    PRIMARY KEY (Код_медкомиссии, Код_заключения),

    FOREIGN KEY (Код_медкомиссии) REFERENCES Медкомиссия (Код_медкомиссии),
    FOREIGN KEY (Код_заключения) REFERENCES  "Заключение врача" (Код_заключения)
);
CREATE TABLE "Гражданин-воинская часть"
(
  Код_гражданина SERIAL,
  Код_части SERIAL,
  Дата_службы DATE,

  PRIMARY KEY (Код_гражданина, Код_части),

  FOREIGN KEY (Код_гражданина) REFERENCES Гражданин (Код_гражданина),
  FOREIGN KEY (Код_части) REFERENCES "Воинская часть" (Код_части)
);