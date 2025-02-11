create table if not exists test_bonus_spot (
    "spot_id" serial not null,
    "dataset_id" integer not null,
    "order_line_id" integer not null,
    "zone" integer not null,
    "network" integer not null,
    "spot_time" timestamp not null
) PARTITION BY RANGE ("spot_id");

create table if not exists test_bonus_spot_2024 PARTITION OF test_bonus_spot
    FOR VALUES FROM (1) TO (2);

create table if not exists test_bonus_spot_2025 PARTITION OF test_bonus_spot
    FOR VALUES FROM (2) TO (3);

create index if not exists "test_bonus_spot_dataset_id_spot_time_idx"
    on "test_bonus_spot" ("dataset_id", ("spot_time"::date));
