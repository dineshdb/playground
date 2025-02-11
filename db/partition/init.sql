create table if not exists test_bonus_spot (
    "spot_id" serial not null,
    "dataset_id" integer not null,
    "order_line_id" integer not null,
    "zone" integer not null,
    "network" integer not null,
    "spot_time" timestamp not null
);

create index if not exists "test_bonus_spot_dataset_id_spot_time_idx"
    on "test_bonus_spot" ("dataset_id", ("spot_time"::date));
