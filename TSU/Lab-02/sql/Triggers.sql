-- Функция проверки выставляемой категории
CREATE OR REPLACE FUNCTION SET_CATEGORY_TYPE () RETURNS TRIGGER AS $$
DECLARE
    total_goden INT;
    total_ogranicheno_goden INT;
    total_vremenno_ne_goden INT;
    total_ne_goden INT;
BEGIN
    -- Подсчет количества заключений для данного гражданина
    SELECT COUNT(*) INTO total_goden
    FROM "Заключение врача"
    WHERE "Код_гражданина" = NEW.Код_гражданина AND "Результат" = 'Годен';

    SELECT COUNT(*) INTO total_ogranicheno_goden
    FROM "Заключение врача"
    WHERE "Код_гражданина" = NEW.Код_гражданина AND "Результат" = 'Ограниченно годен';

    SELECT COUNT(*) INTO total_vremenno_ne_goden
    FROM "Заключение врача"
    WHERE "Код_гражданина" = NEW.Код_гражданина AND "Результат" = 'Временно не годен';

    SELECT COUNT(*) INTO total_ne_goden
    FROM "Заключение врача"
    WHERE "Код_гражданина" = NEW.Код_гражданина AND "Результат" = 'Не годен';

    -- Установка типа категории в соответствии с условиями
    IF total_ne_goden > 0 THEN
        SET NEW.Тип = 'Д';
    ELSEIF total_vremenno_ne_goden > 0 THEN
        SET NEW.Тип = 'Запас';
    ELSEIF total_ogranicheno_goden >= 3 THEN
        SET NEW.Тип = 'Б-2';
    ELSEIF total_ogranicheno_goden = 2 THEN
        SET NEW.Тип = 'Б-1';
    ELSEIF total_ogranicheno_goden >= 1 THEN
        SET NEW.Тип = 'Б';
    ELSE
        SET NEW.Тип = 'А';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

--Триггер, который вызывает функцию проверки категории
CREATE OR REPLACE TRIGGER SET_CATEGORY_TYPE
AFTER INSERT OR UPDATE OR DELETE ON "Категория"
FOR EACH ROW
EXECUTE  FUNCTION  SET_CATEGORY_TYPE();


-- Создание триггера на проверку правильности приказа
/*
CREATE OR REPLACE FUNCTION CHECK_B2_AND_D()
RETURNS TRIGGER AS $$
DECLARE
    citizen_type VARCHAR;
BEGIN
    -- Находим Код_гражданина на основе Код_сотрудника в "Приказ на отправку"
    SELECT "Код_гражданина" INTO citizen_type
    FROM "Категория"
    WHERE "Код_сотрудника" = NEW."Код_сотрудника";

    -- Проверка типа категории гражданина
    IF citizen_type = 'Б-2' THEN
        -- Если категория гражданина Б-2, выбрасываем ошибку
        RAISE EXCEPTION 'Нельзя отправить гражданина с категорией Б-2';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Создание триггера на проверку при вставке записей в "Приказ на отправку"
CREATE TRIGGER check_b2_and_d_trigger
BEFORE INSERT ON "Приказ на отправку"
FOR EACH ROW
EXECUTE FUNCTION CHECK_B2_AND_D();
/*