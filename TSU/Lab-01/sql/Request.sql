--функция, устанавливающая число коек автоматически
CREATE OR REPLACE FUNCTION CHECK_DEFAULT_HOSPITAL_BEDS()
RETURNS TRIGGER AS $$
BEGIN
NEW."ЧИСЛО_КОЕК" = 0;
    RETURN NEW;
END
$$ LANGUAGE plpgsql;

--триггер вызывающий фукнцию CHECK_DEFAULT_HOSPITAL_BEDS
CREATE OR REPLACE TRIGGER CHECK_DEFAULT_HOSPITAL_BEDS_TRIGGER
AFTER INSERT ON "БОЛЬНИЦА"
FOR EACH ROW
EXECUTE FUNCTION CHECK_DEFAULT_HOSPITAL_BEDS();

--функция, обновляющая число коек в больнице при изменении их числа в палатах
CREATE OR REPLACE FUNCTION UPDATE_HOSPITAL_CAPACITY()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE public."БОЛЬНИЦА"
    SET "ЧИСЛО_КОЕК" = (
        SELECT SUM("ЧИСЛО_КОЕК")
        FROM public."ПАЛАТА" P
        WHERE P."КОД_БОЛЬНИЦЫ" = public."БОЛЬНИЦА"."КОД_БОЛЬНИЦЫ"
        ) WHERE "КОД_БОЛЬНИЦЫ" = NEW."КОД_БОЛЬНИЦЫ";

    RETURN NEW;
END
$$LANGUAGE plpgsql;

--триггер вызывающий фукнцию UPDATE_HOSPITAL_CAPACITY
CREATE OR REPLACE TRIGGER UPDATE_HOSPITAL_CAPACITY_TRIGGER
AFTER INSERT OR UPDATE OR DELETE ON "ПАЛАТА"
FOR EACH ROW
EXECUTE FUNCTION UPDATE_HOSPITAL_CAPACITY();

--функция, проверяющая, что значение номера койки не превышает значение атрибута числа коек палаты
CREATE OR REPLACE FUNCTION CHECK_BED_CAPACITY()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW."НОМЕР_КОЙКИ" > (
        SELECT P."ЧИСЛО_КОЕК"
        FROM "ПАЛАТА" P
        WHERE P."КОД_БОЛЬНИЦЫ" = NEW."КОД_БОЛЬНИЦЫ" AND P."НОМЕР_ПАЛАТЫ" = NEW."НОМЕР_ПАЛАТЫ"
    ) THEN
        RAISE EXCEPTION 'НОМЕР КОЙКИ ПРЕВЫШАЕТ КОЛИЧЕСТВО КОЕК В ПАЛАТЕ';
    END IF;
    RETURN NEW;
END
$$ LANGUAGE plpgsql;

--триггер вызывающий фукнцию CHECK_BED_CAPACITY
CREATE OR REPLACE TRIGGER CHECK_BED_CAPACITY_TRIGGER
BEFORE INSERT OR UPDATE ON "РАЗМЕЩЕНИЕ"
FOR EACH ROW
EXECUTE FUNCTION CHECK_BED_CAPACITY();
