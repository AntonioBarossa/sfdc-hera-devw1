    //Rate Category Visibility
    // AFSCDIRATT visibile for all
    export const AF_NODISAL =  { evaluationType: 'notvisible', rateCategories: ['APSCARPRO0','ACDOMRESP0','ACTANTINC0','AITBAGRIC0','AITBNDOME0','AITMINDAP0','AITMINDBP0','AITMNDOME0'] };
    export const AQCNSANNOF =  { evaluationType: 'notvisible', rateCategories: ['APSCARPRO0'] };
    // DEP_CAUZ_ESCL visibile for all
    export const ZGEWKEY =  { evaluationType: 'visible', rateCategories: ['ACAGRICO00','ACAUNOPOT0','ACINDSTR00','ACINTERNO0','ACPOZZI000','ACPROMISC0','ACAUGENER0','ACAUGRUNI0','ACPROMIBI0','ACTANTINC0','AITBAGRIC0','AITBNDOME0','AITMINDAP0','AITMINDBP0','AITMNDOME0'] };
    export const AQVOL_FORF =  { evaluationType: 'visible', rateCategories: ['ACPOZZI000','APSCARPRO0'] };
    export const AF_BOC_IDR =  { evaluationType: 'visible', rateCategories: ['ACTANTINC0'] };
    export const AFNUM_COMP =  { evaluationType: 'visible', rateCategories: ['ACDOMRESP0'] };
    export const AFNCOMP =  { evaluationType: 'visible', rateCategories: ['ACDOMRESP0','ACPROMISC0','ACPROMIBI0'] };
    // AFPAGA_DEP visibile for all
    // AFPAGA_FOG visibile for all
    export const AFUADNR =  { evaluationType: 'visible', rateCategories: ['ACDOMNR000','ACPROMISC0','ACPROMIBI0'] };
    export const AFUADNRdisable =  { evaluationType: 'visible', rateCategories: ['ACDOMNR000'] };
    export const AFUADRS =  { evaluationType: 'visible', rateCategories: ['ACDOMRESP0','ACPROMISC0','ACPROMIBI0'] };
    export const AFUADRSdisable =  { evaluationType: 'visible', rateCategories: ['ACDOMRESP0'] };
    export const AFUND =  { evaluationType: 'visible', rateCategories: ['ACANTINC00','ACAUNOPOT0','ACINTERNO0','ACPOZZI000','ACPROMISC0','ACPUBDIS00','ACPUBNDIS0','ACSUBDIST0','ACAUGENER0','ACANTIN000','ACPISPUB00','ACPROMIBI0','AITBAGRIC0','AITBNDOME0','AITMINDAP0','AITMINDBP0','AITMNDOME0'] };
    export const AFUNDA =  { evaluationType: 'visible', rateCategories: ['ACAGRICO00'] };
    export const AFUNDC =  { evaluationType: 'visible', rateCategories: ['ACARTCOMM0','ACPROMISC0','ACPROMIBI0'] };
    export const AFUNDI =  { evaluationType: 'visible', rateCategories: ['ACINDSTR00','ACAUGRUNI0','ACPROMIBI0'] };
    export const AFUNDIdisable =  { evaluationType: 'visible', rateCategories: ['ACINDSTR00','ACAUGRUNI0'] };
    export const AFUNDZ =  { evaluationType: 'visible', rateCategories: ['ACZOOTECN0','ACAGRIZOO0'] };
    export const AFUNAC =  { evaluationType: 'visible', rateCategories: ['ACARTCOMM0','ACAUGRUNC0','ACPROMIBI0','ACPROMISC0'] }; 
    export const AFUNACdisable =  { evaluationType: 'visible', rateCategories: ['ACARTCOMM0','ACAUGRUNC0'] }; 
    export const NOTDOMESTIC =  { evaluationType: 'visible', rateCategories: ['ACANTINC00','ACAUNOPOT0','ACINTERNO0','ACPOZZI000','ACPROMISC0','ACPUBDIS00','ACPUBNDIS0','ACSUBDIST0','ACAUGENER0','ACANTIN000','ACPISPUB00','ACPROMIBI0','AITBAGRIC0','AITBNDOME0','AITMINDAP0','AITMINDBP0','AITMNDOME0'] }; 
    export const NOTDOMESTICdisable =  { evaluationType: 'visible', rateCategories: ['ACPROMISC0','ACPROMIBI0'] }; //in not
    export const ESDEPCAU =  { evaluationType: 'visible', rateCategories: ['AITBNDOME0','AITMNDOME0'] };
    export const N_A =  { evaluationType: 'visible', rateCategories: ['ACDOMRESP0'] };

    //Rate Category Required

    // AFSCDIRATTreq never required
    // AF_NODISALreq never required
    // AQCNSANNOFreq never required
    export const DEP_CAUZ_ESCLreq = {};
    export const AQCNSANNOFreq = {};
    
    export const DEP_CAUZ_ESCL=  { evaluationType: 'required', rateCategories: ['AITBNDOME0','AITMNDOME0'] };
    export const ZGEWKEYreq =  { evaluationType: 'required', rateCategories: ['AITMINDAP0','AITMINDBP0','AITMNDOME0'] };
    // AQVOL_FORFreq never required
    //export const AF_BOC_IDRreq =  { evaluationType: 'required', rateCategories: ['ACANTIN000'] };
    // AFNUM_COMPreq never required
    export const AFNCOMPreq =  { evaluationType: 'required', rateCategories: ['ACDOMRESP0','ACPROMISC0','ACPROMIBI0'] };
    // AFPAGA_DEP never required
    // AFPAGA_FOG never required
    export const AFUADNRreq =  { evaluationType: 'required', rateCategories: ['ACDOMNR000','ACPROMISC0'] };
    export const AFUADRSreq =  { evaluationType: 'required', rateCategories: ['ACDOMRESP0','ACPROMISC0'] };
    export const AFUNDreq =  { evaluationType: 'required', rateCategories: ['ACANTINC00','ACAUNOPOT0','ACINTERNO0','ACPOZZI000','ACPROMISC0','ACPUBDIS00','ACPUBNDIS0','ACSUBDIST0','ACAUGENER0','AITBAGRIC0','AITBNDOME0','AITMINDAP0','AITMINDBP0','AITMNDOME0'] };
    export const AFUNDAreq =  { evaluationType: 'required', rateCategories: ['ACAGRICO00'] };
    export const AFUNDCreq =  { evaluationType: 'required', rateCategories: ['ACARTCOMM0','ACPROMISC0'] };
    export const AFUNDIreq =  { evaluationType: 'required', rateCategories: ['ACINDSTR00','ACAUGRUNI0'] };
    export const AFUNDZreq =  { evaluationType: 'required', rateCategories: ['ACZOOTECN0'] };
    export const AFUNACreq =  { evaluationType: 'required', rateCategories: ['ACARTCOMM0','ACPROMISC0','ACAUGRUNC0'] };
    export const NOTDOMESTICreq =  { evaluationType: 'visible', rateCategories: ['ACANTINC00','ACAUNOPOT0','ACINTERNO0','ACPOZZI000','ACPROMISC0','ACPUBDIS00','ACPUBNDIS0','ACSUBDIST0','ACAUGENER0','ACANTIN000','ACPISPUB00','AITBAGRIC0','AITBNDOME0','AITMINDAP0','AITMINDBP0','AITMNDOME0'] };
    export const N_Areq =  { evaluationType: 'required', rateCategories: ['ACDOMRESP0'] };

