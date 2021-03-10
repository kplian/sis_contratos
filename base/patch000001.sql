/***********************************I-SCP-VAN-LEG-ETR-0-02/03/2021****************************************/
alter table leg.tcontrato
    add id_carpeta int;

comment
on column leg.tcontrato.id_carpeta is 'proviene del modulo gestion social';

alter table leg.tcontrato
    add constraint tcontrato_tcontrato_id_carpeta_fk
        foreign key (id_carpeta) references mgs.tcarpetas;
/***********************************F-SCP-VAN-LEG-ETR-0-02/03/2021****************************************/