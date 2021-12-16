trigger HDT_AppointmentAgendaEvent on HDT_PEV_AppointmentAgenda__e (after insert) {

    new HDT_TRH_AppointmentAgendaEvent().run();

}