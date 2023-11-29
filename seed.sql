insert into work_orders(title, description, inserted_at, updated_at) values ('flush the warp core', '', now(), now());
insert into work_orders(title, description, inserted_at, updated_at) values ('reverse the polarity', '', now(), now());
insert into work_orders(title, description, inserted_at, updated_at) values ('repair the hull', '', now(), now());
insert into work_orders(title, description, inserted_at, updated_at) values ('decontaminate sick bay', '', now(), now());


insert into work_order_assignments(assigned_employee_id, work_order_id, inserted_at, updated_at) values (1, 1, now(), now()), (2,2,now(),now()), (2,3,now(), now()), (3, 4, now(), now());
