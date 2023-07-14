import { LightningElement, api, track } from 'lwc';
import getInstanceWrapAddressObject from '@salesforce/apex/HDT_UTL_ServicePoint.getInstanceWrapAddressObject';
import getIndirizzo from '@salesforce/apex/HDT_LC_AdvancedSearch.getIndirizzo';
import getIndirizzoFornitura from '@salesforce/apex/HDT_LC_AdvancedSearch.getIndirizzoFornitura';
import getAddressFromAccount from '@salesforce/apex/HDT_LC_AdvancedSearch.getAddressFromAccount';
import getAddressComune from '@salesforce/apex/HDT_WS_HerokuAddressSearch.callServiceCom';
import getAddressInd from '@salesforce/apex/HDT_WS_HerokuAddressSearch.callServiceInd';
import getAddressRev from '@salesforce/apex/HDT_WS_HerokuAddressSearch.callServiceVer';
import { ShowToastEvent } from 'lightning/platformShowToastEvent'
export default class hdtTargetObjectAddressFields extends LightningElement {
    @api objectapiname;
    @api fieldsAddressObject=[];
    @api wrapObjectInput= [];
    @api wrapaddressobject;
    @api fieldsDataReq;
    @api selectedservicepoint;
    @api servicepointretrieveddata ;
    @api herokuAddressServiceData;
    hasAddressBeenVerified = false;
    @track submitedAddressFields = {};
    verifyDisabledOnUpdate = true;
    verifyFieldsAddressDisabled= true;
    disableVerifIndiButton = true;
    disableLocalita= false;
    showSpinner = false;
    @api recordtype;
    @api headertoshow;
    @api checkBoxFieldValue = false;
    @api textFieldValue;
    @api theRecord = {};
    @api stato = 'ITALIA';
    @api provincia;
    @api comune;
    @api cap;
    @api via;
    @api civico;
    @api estenscivico;
    @api codcomunesap;
    @api codstradariosap;
    @api codicelocalita;
    @api localita;
    @api nazione;
    @api IndEstero = false ;
    @api aprimodal = false;
    @api flagverificato =false;
    @track openmodel = false;
    @api viewNazione=false;
    @api viewStato=false;
    @api hideButtonFromFlow;
    tableData = [];
    dataAccountAddress=[];
    dataAddressFornitura=[];
    columnsFornitura=[];
    tableColumnsFornitura = [];
    tableDataFornitura = [];
    tableColumns = [];
    isLoaded = false;
    columns = [];
    originalData = [];
    originalDataFornitura = [];
    pages = [];
    pagesFornitura=[];
    preloading = false;
    @track currentPage = 0;
    @track currentPageFornitura = 0;
    totalPage = 0;
    totalPageFornitura = 0;
    @api accountid;
    @track filterInputWordFornitura = null;
    @track filterInputWord = null;
    confirmButtonDisabled=true;
    rowToSend=[];
    disableCheckBoxFornitura=false;
    disableCheckBoxFatturazione=false;
    booleanForm=false;
    disableStato=false;
    disableProvincia=false;
    disableCap=false;
    disableCodComuneSap=false;
    disableCodViaSap=false;
    @api visibleCopiaResidenza=false;
    @api visibleSelezioneIndirizzi=false;
    @api disableFlagVerificato=false;
    boolProvincia=false;
    boolCap = false;
    boolComune = false;
    boolVia = false;
    boolCivico = false;
    statusCodeComune='';
    localit='';
    @api processtype;
    disableAll=false;
    
    @api openFromFlow = false;
    @track disableConfirmButton

    handleConfirmVerification()
    {
        const closureEvent = new CustomEvent('closemodal');
        this.dispatchEvent(closureEvent);
    }

    get options() {
        return [
            { label: 'AFGHANISTAN', value: 'AFGHANISTAN' },
            { label: 'ALBANIA', value: 'ALBANIA' },
            { label: 'ALGERIA', value: 'ALGERIA' },
            { label: 'ANDORRA', value: 'ANDORRA' },
            { label: 'ANGOLA', value: 'ANGOLA' },
            { label: 'ANGUILLA', value: 'ANGUILLA' },
            { label: 'ANTARTIDE', value: 'ANTARTIDE' },
            { label: 'ANTIGUA E BARBUDA', value: 'ANTIGUA E BARBUDA' },
            { label: 'ANTILLE OLANDESI', value: 'ANTILLE OLANDESI' },
            { label: 'ARABIA SAUDITA', value: 'ARABIA SAUDITA' },
            { label: 'ARGENTINA', value: 'ARGENTINA' },
            { label: 'ARMENIA', value: 'ARMENIA' },
            { label: 'ARUBA', value: 'ARUBA' },
            { label: 'AUSTRALIA', value: 'AUSTRALIA' },
            { label: 'AUSTRIA', value: 'AUSTRIA' },
            { label: 'AZERBAIJAN', value: 'AZERBAIJAN' },
            { label: 'BAHAMAS', value: 'BAHAMAS' },
            { label: 'BAHRAIN', value: 'BAHRAIN' },
            { label: 'BANGLADESH', value: 'BANGLADESH' },
            { label: 'BARBADOS', value: 'BARBADOS' },
            { label: 'BELGIO', value: 'BELGIO' },
            { label: 'BELIZE', value: 'BELIZE' },
            { label: 'BENIN', value: 'BENIN' },
            { label: 'BERMUDA', value: 'BERMUDA' },
            { label: 'BHUTAN', value: 'BHUTAN' },
            { label: 'BIELORUSSIA', value: 'BIELORUSSIA' },
            { label: 'BOLIVIA', value: 'BOLIVIA' },
            { label: 'BOSNIA ERZEGOVINA', value: 'BOSNIA ERZEGOVINA' },
            { label: 'BOTSWANA', value: 'BOTSWANA' },
            { label: 'BRASILE', value: 'BRASILE' },
            { label: 'BRUNEI DARUSSALAM', value: 'BRUNEI DARUSSALAM' },
            { label: 'BULGARIA', value: 'BULGARIA' },
            { label: 'BURKINA FASO', value: 'BURKINA FASO' },
            { label: 'BURUNDI', value: 'BURUNDI' },
            { label: 'CAMBOGIA', value: 'CAMBOGIA' },
            { label: 'CAMERUN', value: 'CAMERUN' },
            { label: 'CANADA', value: 'CANADA' },
            { label: 'CAPO VERDE', value: 'CAPO VERDE' },
            { label: 'CIAD', value: 'CIAD' },
            { label: 'CILE', value: 'CILE' },
            { label: 'CINA', value: 'CINA' },
            { label: 'CIPRO', value: 'CIPRO' },
            { label: 'CITTÀ DEL VATICANO', value: 'CITTÀ DEL VATICANO' },
            { label: 'COLOMBIA', value: 'COLOMBIA' },
            { label: 'COMORE', value: 'COMORE' },
            { label: 'COREA DEL NORD', value: 'COREA DEL NORD' },
            { label: 'COREA DEL SUD', value: 'COREA DEL SUD' },
            { label: 'COSTA D AVORIO', value: 'COSTA D AVORIO' },
            { label: 'COSTA RICA', value: 'COSTA RICA' },
            { label: 'CROAZIA', value: 'CROAZIA' },
            { label: 'CUBA', value: 'CUBA' },
            { label: 'DANIMARCA', value: 'DANIMARCA' },
            { label: 'DOMINICA', value: 'DOMINICA' },
            { label: 'ECUADOR', value: 'ECUADOR' },
            { label: 'EGITTO', value: 'EGITTO' },
            { label: 'EIRE', value: 'EIRE' },
            { label: 'EL SALVADOR', value: 'EL SALVADOR' },
            { label: 'EMIRATI ARABI UNITI', value: 'EMIRATI ARABI UNITI' },
            { label: 'ERITREA', value: 'ERITREA' },
            { label: 'ESTONIA', value: 'ESTONIA' },
            { label: 'ETIOPIA', value: 'ETIOPIA' },
            { label: 'FEDERAZIONE RUSSA', value: 'FEDERAZIONE RUSSA' },
            { label: 'FIJI', value: 'FIJI' },
            { label: 'FILIPPINE', value: 'FILIPPINE' },
            { label: 'FINLANDIA', value: 'FINLANDIA' },
            { label: 'FRANCIA', value: 'FRANCIA' },
            { label: 'GABON', value: 'GABON' },
            { label: 'GAMBIA', value: 'GAMBIA' },
            { label: 'GEORGIA', value: 'GEORGIA' },
            { label: 'GERMANIA', value: 'GERMANIA' },
            { label: 'GHANA', value: 'GHANA' },
            { label: 'GIAMAICA', value: 'GIAMAICA' },
            { label: 'GIAPPONE', value: 'GIAPPONE' },
            { label: 'GIBILTERRA', value: 'GIBILTERRA' },
            { label: 'GIBUTI', value: 'GIBUTI' },
            { label: 'GIORDANIA', value: 'GIORDANIA' },
            { label: 'GRECIA', value: 'GRECIA' },
            { label: 'GRENADA', value: 'GRENADA' },
            { label: 'GROENLANDIA', value: 'GROENLANDIA' },
            { label: 'GUADALUPA', value: 'GUADALUPA' },
            { label: 'GUAM', value: 'GUAM' },
            { label: 'GUATEMALA', value: 'GUATEMALA' },
            { label: 'GUINEA', value: 'GUINEA' },
            { label: 'GUINEA-BISSAU', value: 'GUINEA-BISSAU' },
            { label: 'GUINEA EQUATORIALE', value: 'GUINEA EQUATORIALE' },
            { label: 'GUYANA', value: 'GUYANA' },
            { label: 'GUYANA FRANCESE', value: 'GUYANA FRANCESE' },
            { label: 'HAITI', value: 'HAITI' },
            { label: 'HONDURAS', value: 'HONDURAS' },
            { label: 'HONG KONG', value: 'HONG KONG' },
            { label: 'INDIA', value: 'INDIA' },
            { label: 'INDONESIA', value: 'INDONESIA' },
            { label: 'IRAN', value: 'IRAN' },
            { label: 'IRAQ', value: 'IRAQ' },
            { label: 'ISLANDA', value: 'ISLANDA' },
            { label: 'ISOLA BOUVET', value: 'ISOLA BOUVET' },
            { label: 'ISOLA DI NATALE', value: 'ISOLA DI NATALE' },
            { label: 'ISOLA HEARD E ISOLE MCDONALD', value: 'ISOLA HEARD E ISOLE MCDONALD' },
            { label: 'ISOLA NORFOLK', value: 'ISOLA NORFOLK' },
            { label: 'ISOLE CAYMAN', value: 'ISOLE CAYMAN' },
            { label: 'ISOLE COCOS', value: 'ISOLE COCOS' },
            { label: 'ISOLE COOK', value: 'ISOLE COOK' },
            { label: 'ISOLE FALKLAND', value: 'ISOLE FALKLAND' },
            { label: 'ISOLE FAROE', value: 'ISOLE FAROE' },
            { label: 'ISOLE MARIANNE SETTENTRIONALI', value: 'ISOLE MARIANNE SETTENTRIONALI' },
            { label: 'ISOLE MARSHALL', value: 'ISOLE MARSHALL' },
            { label: 'ISOLE MINORI DEGLI STATI UNITI D AMERICA', value: 'ISOLE MINORI DEGLI STATI UNITI D AMERICA' },
            { label: 'ISOLE SOLOMON', value: 'ISOLE SOLOMON' },
            { label: 'ISOLE TURKS E CAICOS', value: 'ISOLE TURKS E CAICOS' },
            { label: 'ISOLE VERGINI AMERICANE', value: 'ISOLE VERGINI AMERICANE' },
            { label: 'ISOLE VERGINI BRITANNICHE', value: 'ISOLE VERGINI BRITANNICHE' },
            { label: 'ISRAELE', value: 'ISRAELE' },
            { label: 'ITALIA', value: 'ITALIA' },
            { label: 'KAZAKHISTAN', value: 'KAZAKHISTAN' },
            { label: 'KENYA', value: 'KENYA' },
            { label: 'KIRGHIZISTAN', value: 'KIRGHIZISTAN' },
            { label: 'KIRIBATI', value: 'KIRIBATI' },
            { label: 'KUWAIT', value: 'KUWAIT' },
            { label: 'LAOS', value: 'LAOS' },
            { label: 'LESOTHO', value: 'LESOTHO' },
            { label: 'LETTONIA', value: 'LETTONIA' },
            { label: 'LIBANO', value: 'LIBANO' },
            { label: 'LIBERIA', value: 'LIBERIA' },
            { label: 'LIBIA', value: 'LIBIA' },
            { label: 'LIECHTENSTEIN', value: 'LIECHTENSTEIN' },
            { label: 'LITUANIA', value: 'LITUANIA' },
            { label: 'LUSSEMBURGO', value: 'LUSSEMBURGO' },
            { label: 'MACAO', value: 'MACAO' },
            { label: 'MACEDONIA', value: 'MACEDONIA' },
            { label: 'MADAGASCAR', value: 'MADAGASCAR' },
            { label: 'MALAWI', value: 'MALAWI' },
            { label: 'MALDIVE', value: 'MALDIVE' },
            { label: 'MALESIA', value: 'MALESIA' },
            { label: 'MALI', value: 'MALI' },
            { label: 'MALTA', value: 'MALTA' },
            { label: 'MAROCCO', value: 'MAROCCO' },
            { label: 'MARTINICA', value: 'MARTINICA' },
            { label: 'MAURITANIA', value: 'MAURITANIA' },

            { label: 'MAURIZIUS', value: 'MAURIZIUS' },
            { label: 'MAYOTTE', value: 'MAYOTTE' },
            { label: 'MESSICO', value: 'MESSICO' },
            { label: 'MOLDAVIA', value: 'MOLDAVIA' },
            { label: 'MONACO', value: 'MONACO' },
            { label: 'MONGOLIA', value: 'MONGOLIA' },
            { label: 'MONTSERRAT', value: 'MONTSERRAT' },
            { label: 'MOZAMBICO', value: 'MOZAMBICO' },
            { label: 'MYANMAR', value: 'MYANMAR' },
            { label: 'NAMIBIA', value: 'NAMIBIA' },
            { label: 'NAURU', value: 'NAURU' },
            { label: 'NEPAL', value: 'NEPAL' },
            { label: 'NICARAGUA', value: 'NICARAGUA' },
            { label: 'NIGER', value: 'NIGER' },
            { label: 'NIGERIA', value: 'NIGERIA' },
            { label: 'NIUE', value: 'NIUE' },
            { label: 'NORVEGIA', value: 'NORVEGIA' },
            { label: 'NUOVA CALEDONIA', value: 'NUOVA CALEDONIA' },
            { label: 'NUOVA ZELANDA', value: 'NUOVA ZELANDA' },
            { label: 'OMAN', value: 'OMAN' },
            { label: 'PAESI BASSI', value: 'PAESI BASSI' },
            { label: 'PAKISTAN', value: 'PAKISTAN' },
            { label: 'PALAU', value: 'PALAU' },
            { label: 'PANAMÁ', value: 'PANAMÁ' },
            { label: 'PAPUA NUOVA GUINEA', value: 'PAPUA NUOVA GUINEA' },
            { label: 'PARAGUAY', value: 'PARAGUAY' },
            { label: 'PERÙ', value: 'PERÙ' },
            { label: 'PITCAIRN', value: 'PITCAIRN' },
            { label: 'POLINESIA FRANCESE', value: 'POLINESIA FRANCESE' },
            { label: 'POLONIA', value: 'POLONIA' },
            { label: 'PORTOGALLO', value: 'PORTOGALLO' },
            { label: 'PORTO RICO', value: 'PORTO RICO' },
            { label: 'QATAR', value: 'QATAR' },
            { label: 'REGNO UNITO', value: 'REGNO UNITO' },
            { label: 'REPUBBLICA CECA', value: 'REPUBBLICA CECA' },
            { label: 'REPUBBLICA CENTROAFRICANA', value: 'REPUBBLICA CENTROAFRICANA' },
            { label: 'REPUBBLICA DEL CONGO', value: 'REPUBBLICA DEL CONGO' },
            { label: 'REPUBBLICA DEMOCRATICA DEL CONGO', value: 'REPUBBLICA DEMOCRATICA DEL CONGO' },
            { label: 'REPUBBLICA DOMINICANA', value: 'REPUBBLICA DOMINICANA' },
            { label: 'REUNION', value: 'REUNION' },
            { label: 'ROMANIA', value: 'ROMANIA' },
            { label: 'RUANDA', value: 'RUANDA' },
            { label: 'SAHARA OCCIDENTALE', value: 'SAHARA OCCIDENTALE' },
            { label: 'SAINT KITTS E NEVIS', value: 'SAINT KITTS E NEVIS' },
            { label: 'SAINT PIERRE E MIQUELON', value: 'SAINT PIERRE E MIQUELON' },
            { label: 'SAINT VINCENT E GRENADINE', value: 'SAINT VINCENT E GRENADINE' },
            { label: 'SAMOA', value: 'SAMOA' },
            { label: 'SAMOA AMERICANE', value: 'SAMOA AMERICANE' },
            { label: 'SAN MARINO', value: 'SAN MARINO' },
            { label: 'SANTA LUCIA', value: 'SANTA LUCIA' },
            { label: 'SANT ELENA', value: 'SANT ELENA' },
            { label: 'SAO TOME E PRINCIPE', value: 'SAO TOME E PRINCIPE' },
            { label: 'SENEGAL', value: 'SENEGAL' },
            { label: 'SERBIA E MONTENEGRO', value: 'SERBIA E MONTENEGRO' },
            { label: 'SEYCHELLES', value: 'SEYCHELLES' },
            { label: 'SIERRA LEONE', value: 'SIERRA LEONE' },
            { label: 'SINGAPORE', value: 'SINGAPORE' },
            { label: 'SIRIA', value: 'SIRIA' },
            { label: 'SLOVACCHIA', value: 'SLOVACCHIA' },
            { label: 'SLOVENIA', value: 'SLOVENIA' },
            { label: 'SOMALIA', value: 'SOMALIA' },
            { label: 'SPAGNA', value: 'SPAGNA' },
            { label: 'SRI LANKA', value: 'SRI LANKA' },
            { label: 'STATI FEDERATI DELLA MICRONESIA', value: 'STATI FEDERATI DELLA MICRONESIA' },
            { label: 'STATI UNITI D AMERICA', value: 'STATI UNITI D AMERICA' },
            { label: 'SUD AFRICA', value: 'SUD AFRICA' },
            { label: 'SUDAN', value: 'SUDAN' },
            { label: 'SUD GEORGIA E ISOLE SANDWICH', value: 'SUD GEORGIA E ISOLE SANDWICH' },
            { label: 'SURINAME', value: 'SURINAME' },
            { label: 'SVALBARD E JAN MAYEN', value: 'SVALBARD E JAN MAYEN' },
            { label: 'SVEZIA', value: 'SVEZIA' },
            { label: 'SVIZZERA', value: 'SVIZZERA' },
            { label: 'SWAZILAND', value: 'SWAZILAND' },
            { label: 'TAGIKISTAN', value: 'TAGIKISTAN' },
            { label: 'TAILANDIA', value: 'TAILANDIA' },
            { label: 'TAIWAN', value: 'TAIWAN' },
            { label: 'TANZANIA', value: 'TANZANIA' },
            { label: 'TERRITORI BRITANNICI DELL OCEANO INDIANO', value: 'TERRITORI BRITANNICI DELL OCEANO INDIANO' },
            { label: 'TERRITORI FRANCESI DEL SUD', value: 'TERRITORI FRANCESI DEL SUD' },
            { label: 'TIMOR EST', value: 'TIMOR EST' },
            { label: 'TOGO', value: 'TOGO' },
            { label: 'TOKELAU', value: 'TOKELAU' },
            { label: 'TONGA', value: 'TONGA' },
            { label: 'TRINIDAD E TOBAGO', value: 'TRINIDAD E TOBAGO' },
            { label: 'TUNISIA', value: 'TUNISIA' },
            { label: 'TURCHIA', value: 'TURCHIA' },
            { label: 'TURKMENISTAN', value: 'TURKMENISTAN' },
            { label: 'TUVALU', value: 'TUVALU' },
            { label: 'UCRAINA', value: 'UCRAINA' },
            { label: 'UGANDA', value: 'UGANDA' },
            { label: 'UNGHERIA', value: 'UNGHERIA' },
            { label: 'URUGUAY', value: 'URUGUAY' },
            { label: 'UZBEKISTAN', value: 'UZBEKISTAN' },
            { label: 'VANUATU', value: 'VANUATU' },
            { label: 'VENEZUELA', value: 'VENEZUELA' },
            { label: 'VIETNAM', value: 'VIETNAM' },
            { label: 'WALLIS E FUTUNA', value: 'WALLIS E FUTUNA' },
            { label: 'YEMEN', value: 'YEMEN' },
            { label: 'ZAMBIA', value: 'ZAMBIA' },
            { label: 'ZIMBABWE', value: 'ZIMBABWE' },
        ];
        
    }
    handleSelectedValue(event) {
        console.log('handleSelectedValue - event ' +JSON.stringify(event.detail));
        console.log('handleSelectedValue - rowtosend****' + JSON.stringify(this.rowToSend));
        this.template.querySelector('c-hdt-selection-address-response').closeForm();
        if(event.detail['city1'] != null){
            this.comune=event.detail['city1'];
            this.theRecord['Comune']= event.detail['city1'];
        }
        if(event.detail['cityCode'] != null){
            this.codcomunesap=event.detail['cityCode'];
            this.theRecord['Codice Comune SAP']= event.detail['cityCode'];
        }
        if(event.detail['region'] != null){
            this.provincia=event.detail['region'];
            this.theRecord['Provincia']= event.detail['region'];
        }
        if(event.detail['street'] != null){
            this.via=event.detail['street'];
            this.theRecord['Via']= event.detail['Via'];
        }
        if(event.detail['streetCode'] != null){
            console.log('entra in streetCode ' + JSON.stringify(event.detail['streetCode']));
            this.codstradariosap=event.detail['streetCode'];
            this.theRecord['codStradarioSAP']= event.detail['streetCode'];
        }
        if(event.detail['cityPName'] != null){
            console.log('entra in Localita ' + JSON.stringify(event.detail['cityPName']));
            this.localita=event.detail['cityPName'];
            this.theRecord['Localita']= event.detail['cityPName'];
        }
        if(event.detail['cityPCode'] != null){
            console.log('entra in Localita ' + JSON.stringify(event.detail['cityPCode']));
            this.codicelocalita=event.detail['cityPCode'];
            this.theRecord['Codice Localita']= event.detail['cityPCode'];
        }
        if(this.codcomunesap != null && this.codstradariosap != null && this.civico != null){
            this.disableVerifIndiButton = false;
            this.disableConfirmButton = !this.disableVerifIndiButton;
        }
        else{
            this.disableVerifIndiButton = true;
            this.disableConfirmButton = !this.disableVerifIndiButton;
        }
        console.log('handleSelectedValue theRecord : ' + JSON.stringify(this.theRecord));

    }

    handleChange(event) {
        this.comune = event.detail.value;
        this.autocomplete= 'false';
    }



handleAddressFromAccount()
{
    console.log(' getAddressFromAccount START****');
	this.preloading = true;
    console.log('accountiD getAddressFromAccount ****' + JSON.stringify(this.accountid));

	getAddressFromAccount({accountId:this.accountid}).then(data =>
	{
        console.log('data getAddressFromAccount ****' + JSON.stringify(data));
		if(data!= undefined){

            this.via= data['Via'];
            this.civico= data['Civico'];
            this.comune=data['Comune'];		
            this.provincia=data['Provincia'];
            this.cap=data['CAP'];
            this.stato=data['Stato']?.toUpperCase();
			this.estenscivico=data['Est.Civico'];
            this.codcomunesap=data['Codice Comune SAP'];
            this.codstradariosap=data['Codice Via Stradario SAP'];
            this.localita=data['Localita'];
            this.flagverificato=true;

            this.theRecord['Via']= data['Via'];
            this.theRecord['Civico']= data['Civico'];
            this.theRecord['Comune']= data['Comune'];
            this.theRecord['Provincia']= data['Provincia'];
            this.theRecord['CAP']= data['CAP'];
            this.theRecord['Stato']= data['Stato'];
            this.theRecord['Estens.Civico']= data['Est.Civico'];
            this.theRecord['Codice Comune SAP']=data['Codice Comune SAP'];
            this.theRecord['Codice Via Stradario SAP']= data['Codice Via Stradario SAP'];
            this.theRecord['Localita']= data['Localita'];
            this.theRecord['Flag Verificato']= true;
            this.theRecord['Indirizzo Estero']=false;
            if(this.codstradariosap != undefined && this.codstradariosap != ''){
                this.handleAddressVerification();
            }else{
                this.flagverificato=false;
                this.theRecord['Flag Verificato']= false;
                this.alert('Indirizzo da verificare','Attenzione! Indirizzo non censito sullo stradario SAP, inserisci una nuova Via','warn');
            }
            

        }
    });
	
	this.preloading = false;
    console.log(' getAddressFromAccount END****');
}

@api
handleAddressValuesIfSap(servicepointretrieveddata){
    console.log('handleAddressValuesIfSap START');
    console.log('handleAddressValuesIfSap servicepointretrieveddata :' + JSON.stringify(servicepointretrieveddata));
    
    Object.keys(servicepointretrieveddata).forEach(key=>{
        switch(key){
            case 'SupplyCountry__c':
                this.stato = servicepointretrieveddata[key] ;
                this.theRecord['Stato'] = servicepointretrieveddata[key] ;
            break;
            case 'SupplyCity__c':
                this.comune= servicepointretrieveddata[key] ;
                this.theRecord['Comune'] = servicepointretrieveddata[key] ;
            break;
            case 'SupplyProvince__c':
                this.provincia= servicepointretrieveddata[key] ;
                this.theRecord['Provincia'] = servicepointretrieveddata[key] ;
            break;
            case 'SupplyPostalCode__c':
                this.cap = servicepointretrieveddata[key] ;
                this.theRecord['CAP'] = servicepointretrieveddata[key] ;
            break;
            case 'SupplyStreet__c':
                this.via = servicepointretrieveddata[key] ;
                this.theRecord['Via'] = servicepointretrieveddata[key] ;
            break;
            case 'SupplyStreetNumberExtension__c':
                console.log('servicepointretrieveddata[key] *************************************'+JSON.stringify(servicepointretrieveddata[key]));
                this.estenscivico = servicepointretrieveddata[key] ;
                this.theRecord['Estens.Civico'] = servicepointretrieveddata[key] ;
            break;
            case 'SupplyStreetNumber__c':
                console.log('servicepointretrieveddata[key] *************************************'+JSON.stringify(servicepointretrieveddata[key]));
                this.civico = servicepointretrieveddata[key] ;
                this.theRecord['Civico'] = servicepointretrieveddata[key] ;
            break;
            case 'SupplySAPCityCode__c':
                console.log('servicepointretrieveddata[key] *************************************'+JSON.stringify(servicepointretrieveddata[key]));
                this.codcomunesap = servicepointretrieveddata[key] ;
                this.theRecord['Codice Comune SAP'] = servicepointretrieveddata[key] ;
            break;
            case 'SupplySAPStreetCode__c':
                console.log('servicepointretrieveddata[key] *************************************'+JSON.stringify(servicepointretrieveddata[key]));
                this.codstradariosap = servicepointretrieveddata[key] ;
                this.theRecord['Codice Stradario SAP'] = servicepointretrieveddata[key] ;
            break;
            case 'SupplyIsAddressVerified__c':

            console.log('servicepointretrieveddata[key] *************************************'+JSON.stringify(servicepointretrieveddata[key]));
            this.flagverificato = servicepointretrieveddata[key] ;
            this.theRecord['Flag Verificato'] = servicepointretrieveddata[key] ;

            break;
            case 'SupplyPlace__c':

            this.codicelocalita = servicepointretrieveddata[key] ;
            this.theRecord['Localita'] = servicepointretrieveddata[key] ;

            break;
            case 'SupplyPlaceCode__c':

            this.localita = servicepointretrieveddata[key] ;
            this.theRecord['Codice Localita'] = servicepointretrieveddata[key] ;

            break;

        }
     //   this.flagVerificato=true;
     //   this.theRecord['Flag Verificato'] = this.FlagVerificato;
        
    });
    console.log('handleAddressValues END ');
}


    alert(title,msg,variant){
    const event = ShowToastEvent({
        title: title,
        message:  msg,
        variant: variant
    });
    dispatchEvent(event);
}

    handleConfirm(){
        console.log('entra in handleconfirm');
        console.log(' rowToSend**************'+JSON.stringify(this.rowToSend));
        this.preloading = true;
        this.closeModal();
		let data;
        let dataFornitura ;

        if(this.rowToSend['Indirizzo']!=undefined){
            data = this.rowToSend['Indirizzo'].split(",");
            console.log('data after rowToSend**************'+JSON.stringify(data));
        }
        if(this.rowToSend['IndirizzoFornitura']!=undefined){
            dataFornitura = this.rowToSend['IndirizzoFornitura'].split(",");
            console.log('dataFornitura after rowToSend**************'+JSON.stringify(data));
        }

       /* else if(this.rowToSend['Indirizzo Fornitura']!=undefined)
        {
            console.log(' rowToSend**************'+JSON.stringify(this.rowToSend['Indirizzo Fornitura']));
            data = this.rowToSend[''].split(",");
            console.log('data after rowToSend**************'+JSON.stringify(data));

        }*/

     
         if(data!= undefined){
             console.log('entra in data != undefined : ' + JSON.stringify(data));
                this.via= data[1];
                this.civico= data[2];
                this.estenscivico= data[4];
                this.comune=data[0]; 
                this.provincia=data[3];
                this.cap=data[6];
                this.stato=data[5].toUpperCase();

                this.codcomunesap = data[7] !== undefined ? data[7] : '';
                this.codstradariosap = data[8] !== undefined ? data[8] : '';
               // this.IndEstero = data[10] !== undefined ? data[10] : false;

                this.disableVerifIndiButton= false;
                this.disableConfirmButton = !this.disableVerifIndiButton;
                data=[];
         }
         if(dataFornitura!= undefined){
            console.log('entra in dataFornitura != undefined : '+ JSON.stringify(dataFornitura));
            this.comune=dataFornitura[0]; 
            this.via= dataFornitura[1];
            this.civico= dataFornitura[2];
            this.provincia=dataFornitura[3];
            this.estenscivico= dataFornitura[4];
            this.cap=dataFornitura[6];
            this.stato=dataFornitura[5].toUpperCase();

            this.codcomunesap = dataFornitura[7] !== undefined ? dataFornitura[7] : '';
            this.codstradariosap = dataFornitura[8] !== undefined ? dataFornitura[8] : '';
           // this.IndEstero = dataFornitura[10] !== undefined ? dataFornitura[10] : false;

            this.disableVerifIndiButton= false;
            this.disableConfirmButton = !this.disableVerifIndiButton;
            dataFornitura=[];
         }


            this.theRecord['Via']= this.via;
            this.theRecord['Civico']= this.civico;
            this.theRecord['Estens.Civico']= this.estenscivico;
            this.theRecord['Comune']= this.comune;
            this.theRecord['Provincia']= this.provincia;
            this.theRecord['CAP']= this.cap;
            this.theRecord['Stato']= this.stato;

            this.theRecord['CodiceComuneSAP'] = this.codcomunesap;
            this.theRecord['CodiceViaStradarioSAP'] = this.codstradariosap;
            this.theRecord['IndirizzoEstero'] = this.IndEstero;
           // this.theRecord['Flag Verificato'] = this.FlagVerificato;
           this.theRecord['Flag Verificato'] = true;
           if(this.codstradariosap != undefined && this.codstradariosap != ''){
                this.handleAddressVerification();
            }else{
                this.flagverificato=false;
                this.theRecord['Flag Verificato']= true;
                this.alert('Indirizzo da verificare','Attenzione! Indirizzo non censito sullo stradario SAP, inserisci una nuova Via','warn');
            } 
           

        this.preloading = false;
        console.log(' THERECORD**************'+JSON.stringify(this.theRecord));
        console.log('esce da handleconfirm');

    }

    getSelectedServicePoint(event){
        console.log('getSelectedServicePoint START');
  
        
        this.disableCheckBoxFornitura=true;
        this.preloading = true;
        let selectedRows = event.detail.selectedRows;
        this.confirmButtonDisabled = (selectedRows === undefined || selectedRows.length == 0) ? true : false;
        this.rowToSend = (selectedRows[0] !== undefined) ? selectedRows[0]: {};
        console.log('rowToSend ******' + JSON.stringify(this.rowToSend));
        this.preloading = false;
        this.flagverificato=true;
        this.theRecord['Flag Verificato']= true;
        console.log('getSelectedServicePoint END');
    }
    
    getSelectedAddress(event){
        console.log('getSelectedAddress START');

        this.disableCheckBoxFatturazione=true;
        this.preloading = true;
        let selectedRows = event.detail.selectedRows;
        this.confirmButtonDisabled = (selectedRows === undefined || selectedRows.length == 0) ? true : false;
        this.rowToSend = (selectedRows[0] !== undefined) ? selectedRows[0]: {};
        console.log('rowToSend ******' + JSON.stringify(this.rowToSend));
        this.preloading = false;
        this.flagverificato=true;
        this.theRecord['Flag Verificato']= true;
        console.log('getSelectedAddress END');
    }


    handleFilterDataTableFornitura(event) {
        let val = event.target.value;
        let self = this;
        let data;
        setTimeout(function () {
            data = JSON.parse(JSON.stringify(self.originalDataFornitura));
            if (val.trim() !== '') {
                data = data.filter(row => {
                    let found = false;
                    Object.values(row).forEach(v => {
                        if (v !== undefined && null != v.toLowerCase() && (v.toLowerCase().search(val.toLowerCase())  !== -1 ) ) {
                            found = true;
                        }
                    });
                    if (found) return row;
                })
            }
            self.createTableFornitura(data); // redesign table
            self.currentPageFornitura = 0; // reset page
        }, 1000);
    }

    handleFilterDataTable(event) {
        let val = event.target.value;
        let self = this;
        let data;
        setTimeout(function () {
            data = JSON.parse(JSON.stringify(self.originalData));
            if (val.trim() !== '') {
                data = data.filter(row => {
                    let found = false;
                    Object.values(row).forEach(v => {
                        if (v !== undefined && null != v.toLowerCase() && (v.toLowerCase().search(val.toLowerCase())  !== -1 ) ) {
                            found = true;
                        }
                    });
                    if (found) return row;
                })
            }
            self.createTable(data); // redesign table
            self.currentPage = 0; // reset page
        }, 1000);
    }

    @api
    submitIndirizzo(){
        this.preloading = true;
            console.log('AccountId *******************'+ JSON.stringify(this.accountid));
            this.columns = [
                {label: '', fieldName: 'Indirizzo', type: 'Text'},
           ];
            let dataForTable ='';
            getIndirizzo({accountId:this.accountid}).then(data =>{

                console.log('****getIndirizzo: '+  JSON.stringify(data));
                
           
                    
                    if(data.comune != undefined){
                        dataForTable += data.comune;
                        if(data.comune!=', '){
                            console.log('entra in Comune else : ');
                            dataForTable+=',';
                        }
                    }
                    if(data.via != undefined){
                        dataForTable += data.via;
                        if(data.via!=', '){
                            console.log('entra in Via else : ');
                            dataForTable+=',';
                        }
                    }
                    if(data.civico != undefined){
                        dataForTable += data.civico;
                        if(data.civico!=', '){
                            console.log('entra in civico else : ');
                            dataForTable+=',';
                        }
                    }
                    if(data.provincia != undefined){
                        dataForTable += data.provincia;
                        if(data.provincia!=', '){
                            console.log('entra in Provincia else : ');
                            dataForTable+=',';
                        }
                    }
                    if(data.estensCivico != undefined){
                        dataForTable += data.estensCivico;
                        if(data.estensCivico!=', '){
                            console.log('entra in EstensCivico else : ');
                            dataForTable+=',';
                        }
                    }
                    if(data.stato != undefined){
                        dataForTable += data.stato;
                        if(data.stato!=', '){
                            console.log('entra in Stato else : ');
                            dataForTable+=',';
                        }
                    }
                    if(data.cap != undefined){
                        dataForTable += data.cap ;
                        if(data.cap!=', '){
                            console.log('entra in CAP else : ');
                            dataForTable+=',';
                        }
                    }
                    if(data.codiceComuneSAP != undefined){
                        dataForTable += data.codiceComuneSAP;
                        if(data.codiceComuneSAP!=', '){
                            console.log('entra in CodiceComuneSAP else : ');
                            dataForTable+=',';
                        }
                    }
                    if(data.codiceViaStradarioSAP != undefined){
                        dataForTable += data.codiceViaStradarioSAP;
                        if(data.codiceViaStradarioSAP!=', '){
                            console.log('entra in CodiceViaStradarioSAP else : ');
                            dataForTable+=' ';
                        }
                    }


                   this.dataAccountAddress = [{
    
                    'Indirizzo': dataForTable
                    
                }];

                   
                console.log('dataForTable ' + dataForTable );
                
                this.preloading = false;
                console.log('data getIndirizzo : ' + data.length)
                if (data!=undefined) {
                    this.originalData = JSON.parse(JSON.stringify(dataForTable));
                   // this.createTable(dataForTable);
                   // this.formatTableHeaderColumns(dataForTable);
                    this.openmodel = true;
                    this.isLoaded = true;
                    console.log('getIndirizzo pages: '+ JSON.stringify(this.pages));
                    console.log('getIndirizzo tableData: '+ JSON.stringify(this.tableData));

                } else {
                    this.alert('Dati tabella','Nessun record trovato','warn')
                    this.tableData=[];
                    this.tableData = data;
                }
            });
            
            getIndirizzoFornitura({accountId:this.accountid}).then(data =>{

                console.log('****getIndirizzoFornitura: ', JSON.stringify(data));
                this.preloading = false;
                this.dataAddressFornitura=[];
                let dataForTableForn ='';
                let i=1;
                let searchkey = 'INDIRIZZOFORNITURA'+i;
                this.columnsFornitura = [
                    {label: '', fieldName: 'IndirizzoFornitura', type: 'Text'},
               ];
                data.forEach(element=>{
                    i++;
                    console.log('****count searchkey : '+  JSON.stringify(searchkey));
                    dataForTableForn ='';
                    console.log('****element INDIRIZZOFORNITURA: '+  JSON.stringify(element));
                    if(element.comune !== undefined && element.comune !== null && element.comune !== ''){
                        dataForTableForn += element.comune + ',';
                    }
                    if(element.via !== undefined && element.via !== null && element.via !== ''){
                        dataForTableForn += element.via + ',';
                    }
                    if(element.civico !== undefined && element.civico !== null && element.civico !== ''){
                        dataForTableForn += element.civico + ',';
                    }
                    if(element.provincia !== undefined && element.provincia !== null && element.provincia !== ''){
                        dataForTableForn += element.provincia+ ',';
                    }
                    if(element.estensCivico !== undefined && element.estensCivico !== null){
                        dataForTableForn += element.estensCivico + ',';
                    }
                    if(element.stato !== undefined && element.stato !== null && element.stato !== ''){
                        dataForTableForn += element.stato + ',';
                    }
                    if(element.cap !== undefined && element.cap !== null && element.cap !== ''){
                        dataForTableForn += element.cap + ',';
                    }
                    if(element.codiceComuneSAP !== undefined && element.codiceComuneSAP !== null && element.codiceComuneSAP !== ''){
                        dataForTableForn += element.codiceComuneSAP + ',';
                    }
                    if(element.codiceViaStradarioSAP !== undefined && element.codiceViaStradarioSAP !== null && element.codiceViaStradarioSAP !== ''){
                        dataForTableForn += element.codiceViaStradarioSAP;
                    }

                    console.log('dataForTableForn lenght : ' + dataForTableForn.length);

                    console.log('dataForTable ' + dataForTableForn );

                    this.dataAddressFornitura.push({'IndirizzoFornitura': dataForTableForn});                    
                    
                }); 
                
                if (data.length > 0) {
                    this.originalDataFornitura = JSON.parse(JSON.stringify(this.dataAddressFornitura));
                    this.createTableFornitura(this.dataAddressFornitura);
                    this.formatTableHeaderColumnsFornitura(this.dataAddressFornitura);
                    this.openmodel = true;
                    this.isLoaded = true;
                    console.log('getIndirizzoFornitura pages: '+ JSON.stringify(this.pagesFornitura));
                    console.log('tableDataFornitura******'+ JSON.stringify(this.tableDataFornitura));
                } else {
                    this.alert('Dati tabella','Nessun record trovato','warn')
                    this.tableDataFornitura=[];
                    this.tableDataFornitura = data;
                }
            });
       
        
    }

     /**
     * Create header for Data-Table header with original data
     */
      formatTableHeaderColumns(rowData) {
        let columns = [];
        this.tableColumns = [];
        rowData.forEach(row => {
            let keys = Object.keys(row);
            columns = columns.concat(keys);
        });
        let columnsUniq = [...new Set(columns)];
        columnsUniq.forEach(field => this.tableColumns.push({label: field, fieldName: field}));
    }

    formatTableHeaderColumnsFornitura(rowData) {
        let columns = [];
        this.tableColumnsFornitura = [];
        rowData.forEach(row => {
            let keys = Object.keys(row);
            columns = columns.concat(keys);
        });
        let columnsUniq = [...new Set(columns)];
        columnsUniq.forEach(field => this.tableColumnsFornitura.push({label: field, fieldName: field}));
    }

    /**
     * Create Data-Table
     */
    createTable(data) {
        console.log('data table ' + JSON.stringify(data));
        let i, j, temporary, chunk = 5;
        this.pages = [];
        for (i = 0, j = data.length; i < j; i += chunk) {
            temporary = data.slice(i, i + chunk);
            this.pages.push(temporary);
        }
        this.totalPage = this.pages.length;
        this.reLoadTable();
    }

    createTableFornitura(data) {
        console.log('data table fornitura ' + JSON.stringify(data));

        let i, j, temporary, chunk = 5;
        this.pagesFornitura = [];
        for (i = 0, j = data.length; i < j; i += chunk) {
            temporary = data.slice(i, i + chunk);
            this.pagesFornitura.push(temporary);
        }
        this.totalPageFornitura = this.pagesFornitura.length;
        this.reLoadTableFornitura();
    }

    reLoadTable() {
        this.tableData=[];
        this.tableData = this.pages[this.currentPage];

        console.log('currentPage********'+ this.currentPage);
        console.log('tableData********'+ JSON.stringify(this.tableData));

    }

    reLoadTableFornitura() {
        this.tableDataFornitura=[];
        this.tableDataFornitura = this.pagesFornitura[this.currentPageFornitura];

        console.log('tableDataFornitura********'+ JSON.stringify(this.tableDataFornitura));

    }

    nextPage() {
        if (this.currentPage < this.totalPage) this.currentPage += 1;
        this.reLoadTable();
    }

    previousPage() {
        if (this.currentPage > 1) this.currentPage-= 1 ;
        this.reLoadTable();
    }

    nextPageFornitura() {
        if (this.currentPageFornitura < this.totalPageFornitura - 1) this.currentPageFornitura++;
        this.reLoadTableFornitura();
    }

    previousPageFornitura() {
        if (this.currentPageFornitura > 0) this.currentPageFornitura--;
        this.reLoadTableFornitura();
    }

    get getCurrentPage() {
        if (this.totalPage===0) return 0;
        return this.currentPage + 1;
    }

    get getCurrentPageFornitura() {
        if (this.totalPageFornitura===0) return 0;
        return this.currentPageFornitura + 1;
    }
    
    openmodal() {
        this.openmodel = true;
    }
    closeModal() {
        this.openmodel = false;
    } 

    submitAddressModal(){
        this.openMod();
    }


@api
handleAddressValues(servicepointretrieveddata){
    console.log('handleAddressValues START - servicepointretrieveddata :' + JSON.stringify(servicepointretrieveddata));
    Object.keys(servicepointretrieveddata).forEach(key=>{
        switch(key){
            case 'Stato':
                this.stato = servicepointretrieveddata[key] ;
                this.theRecord['Stato'] = servicepointretrieveddata[key] ;
            break;
            case 'stato':
                this.stato = servicepointretrieveddata[key] ;
                this.theRecord['Stato'] = servicepointretrieveddata[key] ;
            break;
            case 'Provincia':
                this.provincia= servicepointretrieveddata[key] ;
                this.theRecord['Provincia'] = servicepointretrieveddata[key] ;
            break;
            case 'provincia':
                this.provincia= servicepointretrieveddata[key] ;
                this.theRecord['Provincia'] = servicepointretrieveddata[key] ;
            break;
            case 'Comune':
                this.comune= servicepointretrieveddata[key] ;
                this.theRecord['Comune'] = servicepointretrieveddata[key] ;
            break;
            case 'comune':
                this.comune= servicepointretrieveddata[key] ;
                this.theRecord['Comune'] = servicepointretrieveddata[key] ;
            break;
            case 'CAP':
                this.cap = servicepointretrieveddata[key] ;
                this.theRecord['CAP'] = servicepointretrieveddata[key] ;
            break;
            case 'cap':
                this.cap = servicepointretrieveddata[key] ;
                this.theRecord['CAP'] = servicepointretrieveddata[key] ;
            break;
            case 'Via':
                this.via = servicepointretrieveddata[key] ;
                this.theRecord['Via'] = servicepointretrieveddata[key] ;
            break;
            case 'via':
                this.via = servicepointretrieveddata[key] ;
                this.theRecord['Via'] = servicepointretrieveddata[key] ;
            break;
            case 'Civico':
                console.log('servicepointretrieveddata[key] *************************************'+JSON.stringify(servicepointretrieveddata[key]));
                this.civico = servicepointretrieveddata[key] ;
                this.theRecord['Civico'] = servicepointretrieveddata[key] ;
            break;
            case 'civico':
                console.log('servicepointretrieveddata[key] *************************************'+JSON.stringify(servicepointretrieveddata[key]));
                this.civico = servicepointretrieveddata[key] ;
                this.theRecord['Civico'] = servicepointretrieveddata[key] ;
            break;
            case 'EstensCivico':
                console.log('servicepointretrieveddata[key] *************************************'+JSON.stringify(servicepointretrieveddata[key]));
                this.estenscivico = servicepointretrieveddata[key] ;
                this.theRecord['Estens.Civico'] = servicepointretrieveddata[key] ;
            break;
            case 'estensCivico':
                console.log('servicepointretrieveddata[key] *************************************'+JSON.stringify(servicepointretrieveddata[key]));
                this.estensCivico = servicepointretrieveddata[key] ;
                this.theRecord['Estens.Civico'] = servicepointretrieveddata[key] ;
            break;
            case 'CodiceComuneSAP':
                console.log('servicepointretrieveddata[key] *************************************'+JSON.stringify(servicepointretrieveddata[key]));
                this.codcomunesap = servicepointretrieveddata[key] ;
                this.theRecord['Codice Comune SAP'] = servicepointretrieveddata[key] ;
            break;
            case 'codiceComuneSAP':
                console.log('servicepointretrieveddata[key] *************************************'+JSON.stringify(servicepointretrieveddata[key]));
                this.codcomunesap = servicepointretrieveddata[key]; 
                this.codComuneSAP = servicepointretrieveddata[key];
                this.theRecord['Codice Comune SAP'] = servicepointretrieveddata[key];
            break;
            case 'CodiceViaStradarioSAP':
                console.log('servicepointretrieveddata[key] *************************************'+JSON.stringify(servicepointretrieveddata[key]));
                this.codstradariosap = servicepointretrieveddata[key] ;
                this.theRecord['Codice Via Stradario SAP'] = servicepointretrieveddata[key] ;
            break;
            case 'codiceViaStradarioSAP':
                console.log('servicepointretrieveddata[key] *************************************'+JSON.stringify(servicepointretrieveddata[key]));
                this.codstradariosap = servicepointretrieveddata[key];
                this.codStradarioSAP = servicepointretrieveddata[key];
                this.theRecord['Codice Via Stradario SAP'] = servicepointretrieveddata[key] ;
            break;
            case 'IndirizzoEstero':
                this.IndEstero = servicepointretrieveddata[key] ;
                this.theRecord['Indirizzo Estero'] = this.IndEstero;

            break;
            case 'indirizzoEstero':
                this.IndEstero = servicepointretrieveddata[key] ;
                this.theRecord['Indirizzo Estero'] = this.IndEstero;

            break;
            case 'FlagVerificato':

                console.log('servicepointretrieveddata[key] *************************************'+JSON.stringify(servicepointretrieveddata[key]));
                this.flagverificato = servicepointretrieveddata[key] ;
                this.theRecord['Flag Verificato'] = this.flagverificato;

            break;
            case 'flagVerificato':

                console.log('servicepointretrieveddata[key] *************************************'+JSON.stringify(servicepointretrieveddata[key]));
                this.flagverificato = servicepointretrieveddata[key] ;
                this.flagVerificato = servicepointretrieveddata[key] ;
                this.theRecord['Flag Verificato'] = this.flagVerificato;

            break;
            case 'AbilitaVerifica':
                this.disableVerifIndiButton = servicepointretrieveddata[key];
                this.disableConfirmButton = !this.disableVerifIndiButton;
            break;
            case 'abilitaVerifica':
                this.disableVerifIndiButton = servicepointretrieveddata[key];
                this.disableConfirmButton = !this.disableVerifIndiButton;
            break;
            case 'Localita':

                console.log('servicepointretrieveddata[key] *************************************'+JSON.stringify(servicepointretrieveddata[key]));
                this.localita = servicepointretrieveddata[key] ;
                this.theRecord['Localita'] = this.localita;

            break;
            case 'localita':

                console.log('servicepointretrieveddata[key] *************************************'+JSON.stringify(servicepointretrieveddata[key]));
                this.Localita = servicepointretrieveddata[key] ;
                this.theRecord['Localita'] = this.Localita;

            break;
        }

    });
    console.log('cod')
    console.log('### TheRecord >>> ' + JSON.stringify(this.theRecord));
    console.log('handleAddressValues END ');
}


@api
handleCheckBoxChange(event){
    console.log('event detail : ******++'+ JSON.stringify(event.target.name));
    
        this.checkBoxFieldValue = event.target.checked;
        this.theRecord[event.target.name] = event.target.checked;
        console.log(event.target.name + ' now is set to ' + event.target.checked); 
        switch(event.target.name){
            case 'Indirizzo Estero':
                console.log('entra in indirizzo estero case');
                this.IndEstero = event.target.checked;
                if(event.target.checked==true){
                    this.stato='ESTERO';
                    if(this.objectapiname!='ServicePoint__c'){
                        this.viewNazione=true;
                        this.viewStato=false;
                    }

                }else{
                    this.stato='ITALIA';
                    this.viewNazione=false;
                    this.viewStato=true;
                }
                this.flagVerificatoFalse();
                break;
            case 'Flag Verificato':
                console.log('entra in Flag Verificato case');

                this.flagverificato =  event.target.checked;
                break;
        }

        this.disableFieldByIndEstero();



        
        console.log('theRecord *********'+ JSON.stringify(this.theRecord));
}

flagVerificatoFalse(){
    console.log('flagVerificatoFalse START');
    this.theRecord['Flag Verificato'] = false;

    this.flagverificato = false;
    console.log('Flag Verificato : '+JSON.stringify(this.flagverificato));
    console.log('flagVerificatoFalse END');
}

@api
disableFieldByIndEstero(){

    console.log('disableFieldByIndEstero START');
    if(this.IndEstero === false ){
        console.log('entra in indEstero false');
        this.disableStato=true;
        this.disableProvincia=true;
        this.disableCap=true;
        this.disableCodComuneSap=true;
        this.disableCodViaSap=true;
       
        this.boolProvincia=false;
        this.boolCap = false;
        this.boolComune = false;
        this.boolVia = false;
        this.boolCivico = false;

    }
    if(this.IndEstero === true)
    {
        console.log('entra in indEstero true');
        this.disableStato=false;
        this.disableProvincia=false;
        this.disableCap=false;
        this.disableCodComuneSap=false;
        this.disableCodViaSap=false;

        this.boolProvincia=true;
        this.boolCap = true;
        this.boolComune = true;
        this.boolVia = true;
        this.boolCivico = true;
    }
    console.log('disableFieldByIndEstero END');

}


@api
handleChangeComune(event){
    console.log('event value : ******++'+ JSON.stringify(event.target.value));
    console.log('event detail : ******++'+ JSON.stringify(event.target.detail));
    console.log('entra qui+++++++++++++++++++++++++++');
    
    if(this.IndEstero==true){

    }else{

    
    if((event.target.value.length==3 && event.target.name =='Comune')){
        getAddressComune({city:event.target.value}).then(data =>
            {
                
                console.log("******HOLAHOLA:" + JSON.stringify(data));
                if(data['statusCode'] == 200 && data['prestazione'].length > 0){
                    this.statusCodeComune = data['statusCode'];
                    console.log("Sucessoooooooooooo:" + JSON.stringify(data));
                    this.herokuAddressServiceData = data['prestazione'];
                    this.headertoshow = 'Comune';
                    console.log('TryTestHOLA210');
                    if(this.IndEstero==true)
                    {
                        console.log('TryTestHOLA211');
                        this.booleanForm=false;
                    }
                    else
                    {
                        this.booleanForm=true;
                        console.log('TryTestHOLA212');
                        this.template.querySelector('c-hdt-selection-address-response').openedForm();
                        this.template.querySelector('c-hdt-selection-address-response').valorizeTable(data['prestazione'],'Citta');
                        this.template.querySelector('c-hdt-selection-address-response').handleFilterDataTable(event);
                        console.log('TryTestHOLA213');
                    }
                    
                }
                else{
                    let event2;
                    if(data['statusCode'] != 200){
                        event2 = new ShowToastEvent({
                            title: 'Errore',
                            variant: 'error',
                            message: "errore di connessione, riprovare o contattare l'amministratore"
                        });
                        
                    }
                    else{
                        event2 = new ShowToastEvent({
                            title: 'Errore',
                            variant: 'error',
                            message: 'Non sono presenti Comuni corrispondenti ai caratteri inseriti. Digitare nuovamente per effettuare una nuova ricerca.'
                        });
                    }
                    this.dispatchEvent(event2);
                }
                
    
    
        });
    }

        if(this.statusCodeComune==200){
            console.log('entra in if statusCodeComune == 200');
            this.template.querySelector('c-hdt-selection-address-response').handleFilterDataTable(event);

        }
    }
    

        this.textFieldValue = event.target.value;
        this.theRecord[event.target.name] = event.target.value;
        console.log(event.target.name + ' now is set to ' + event.target.value);
        console.log('theRecord *********'+ JSON.stringify(this.theRecord));
        switch(event.target.name){
            case 'Civico':
                this.civico = event.target.value;
                break;
            case 'Comune':
                this.comune =  event.target.value;
                break;
            case 'Stato':
                this.stato = event.target.value;
                break;
            case 'Provincia':
                this.provincia = event.target.value;
                break;
            case 'Via':
                this.via= event.target.value;
                
                break;
            case 'CAP':
                this.cap= event.target.value;
                break;
            case 'Estens.Civico':
                this.estenscivico = event.target.value;
                console.log('estensione civico'+ JSON.stringify(event.target.value));
                break;
            case 'Codice Comune SAP':
                this.codcomunesap = event.target.value;
                console.log('codComSAP'+ JSON.stringify(this.estenscivico));
                break;
            case 'Codice Via Stradario SAP':
                this.codstradariosap = event.target.value;
                console.log('codStradario'+ JSON.stringify(this.estenscivico));
                break;
        }
        this.flagVerificatoFalse();
        this.wrapaddressobject = this.toObjectAddressInit(this.theRecord);
       
        console.log('wrapaddressobject -handleTextChange ********************'+ JSON.stringify(this.wrapaddressobject));

}


@api
handleChangeIndirizz(event){
    console.log('event value : ******++'+ JSON.stringify(event.target.value));
    console.log('event detail : ******++'+ JSON.stringify(event.target.detail));
    console.log('entra qui+++++++++++++++++++++++++++');
    if(this.IndEstero==true){

    }else{

    
        if((event.target.value.length==5 && event.target.name =='Via')){
            getAddressInd({street:event.target.value,cityCode:this.codcomunesap}).then(data =>
                {
                    console.log("******HOLAHOLA:" + JSON.stringify(data));
                    if(data['statusCode'] == 200 && data['prestazione'].length > 0){
                        console.log("Sucess:" + JSON.stringify(data));
                        this.herokuAddressServiceData = data['prestazione'];
                        this.headertoshow = 'Via';
                        this.booleanForm=false;
                        this.booleanForm=true;

                        this.template.querySelector('c-hdt-selection-address-response').openedForm2();
                        this.template.querySelector('c-hdt-selection-address-response').valorizeTable(data['prestazione'],'Via');
                    }
                    else{
                        let event2;
                        if(data['statusCode'] != 200){
                            event2 = new ShowToastEvent({
                                title: 'Errore',
                                variant: 'error',
                                message: "errore di connessione, riprovare o contattare l'amministratore"
                            });
                            
                        }
                        else{
                            event2 = new ShowToastEvent({
                                title: 'Errore',
                                variant: 'error',
                                message: 'Non sono presenti Indirizzi corrispondenti ai caratteri inseriti . Digitare nuovamente per effettuare una nuova ricerca.',
                            });
                        }
                        this.dispatchEvent(event2);
                    }
                    
        
        
            });
        }
    }
    

        this.textFieldValue = event.target.value;
        this.theRecord[event.target.name] = event.target.value;
        console.log(event.target.name + ' now is set to ' + event.target.value);
        console.log('theRecord *********'+ JSON.stringify(this.theRecord));
        switch(event.target.name){
            case 'Civico':
                this.civico = event.target.value;
                break;
            case 'Comune':
                this.comune =  event.target.value;
                break;
            case 'Stato':
                this.stato = event.target.value;
                break;
            case 'Provincia':
                this.provincia = event.target.value;
                break;
            case 'Via':
                this.via= event.target.value;
                break;
            case 'CAP':
                this.cap= event.target.value;
                break;
            case 'Estens.Civico':
                this.estenscivico = event.target.value;
                console.log('estensione civico'+ JSON.stringify(event.target.value));
                break;
            case 'Codice Comune SAP':
                this.codcomunesap = event.target.value;
                console.log('codComSAP'+ JSON.stringify(this.estenscivico));
                break;
            case 'Codice Via Stradario SAP':
                this.codstradariosap = event.target.value;
                console.log('codStradario'+ JSON.stringify(this.estenscivico));
                break;
        }
        this.flagVerificatoFalse();
        this.wrapaddressobject = this.toObjectAddressInit(this.theRecord);
        console.log('wrapaddressobject -handleTextChange ********************'+ JSON.stringify(this.wrapaddressobject));

}






@api
handleTextChange(event){
    console.log('event value : ******++'+ JSON.stringify(event.target.value));
    console.log('event detail : ******++'+ JSON.stringify(event.target.detail));
    console.log('entra qui+++++++++++++++++++++++++++');
    
    if((event.target.value.length>2 && event.target.name =='Comune')||(event.target.value.length>4 && event.target.name =='Via')){
        this.booleanForm=true;
        this.template.querySelector('c-hdt-selection-address-response').openedForm();
        this.template.querySelector('c-hdt-selection-address-response').connectedCallback();
    }

        this.textFieldValue = event.target.value;
        this.theRecord[event.target.name] = event.target.value;
        console.log(event.target.name + ' now is set to ' + event.target.value);
        console.log('theRecord *********'+ JSON.stringify(this.theRecord));
        switch(event.target.name){
            case 'Civico':
                this.civico = event.target.value;
                break;
            case 'Comune':
                this.comune =  event.target.value;
                break;
            case 'Stato':
                this.stato = event.target.value;
                break;
            case 'Provincia':
                this.provincia = event.target.value;
                break;
            case 'Via':
                this.via= event.target.value;
                break;
            case 'CAP':
                this.cap= event.target.value;
                break;
            case 'Estens.Civico':
                this.estenscivico = event.target.value;
                break;
            case 'Codice Comune SAP':
                this.codcomunesap = event.target.value;
                break;
            case 'Codice Via Stradario SAP':
                this.codstradariosap = event.target.value;
                break;
            case 'Localita':
                this.localit = event.target.value;
                break;
        }
        this.flagVerificatoFalse();
        
        this.wrapaddressobject = this.toObjectAddressInit(this.theRecord);
        console.log('wrapaddressobject -handleTextChange ********************'+ JSON.stringify(this.wrapaddressobject));
        if(this.codcomunesap != null && this.codstradariosap != null && this.civico != null){
            this.disableVerifIndiButton = false;
            this.disableConfirmButton = !this.disableVerifIndiButton;
        }
        else{
            this.disableVerifIndiButton = true;
            this.disableConfirmButton = !this.disableVerifIndiButton;
        }
    
}

@api
    handleAddressFields(){
        console.log('saveAddressField - wrapaddressobject START '+ JSON.stringify(this.theRecord));
        if(this.theRecord['Indirizzo Estero'] === undefined){
            this.theRecord['Indirizzo Estero'] = false;
        }
        return this.theRecord;

    }

@api
disabledverifyFieldsAddressDisabled(){
    this.verifyFieldsAddressDisabled= false;
}

@api
    toObjectAddressInit(data){

        let fieldsDataObject = [];
        
        Object.keys(data).forEach(keys=> {
        
           

                fieldsDataObject.push(
                    {
                        fieldname: keys,
                        required : false,
                        value: data[keys],
                        disabled: false
                    }
                ) 

        });

        return fieldsDataObject;
    }

@api
    connectedCallback()
    {
        this.disableFlagVerificato=true;
        console.log('hdtTargetObjectAddressFields - fieldAddressObject : '+ JSON.stringify(this.fieldsaddressobject));
        console.log('connectedCallback  START + theRecord : '+JSON.stringify(this.theRecord));
        console.log('connectedCallback   objectApiName : '+JSON.stringify(this.objectapiname));
        if(this.hideButtonFromFlow || this.objectapiname=='Account' || this.accountid == null){    //MODIFICA 28/07/22 - 13/01/23 marco.arci@webresults.it -> se non c'è un contesto di account, non mostrari i due pulsanti
            this.visibleCopiaResidenza=false;
            this.visibleSelezioneIndirizzi=false;
        }else{
            this.visibleCopiaResidenza=true;
            this.visibleSelezioneIndirizzi=true;
        }

        if(this.objectapiname!='ServicePoint__c')
        {
            if(this.IndEstero==false)
            {
                this.viewNazione=false;
                this.viewStato=true;
                this.theRecord['Stato'] = this.stato;
            }
            else
            {
                this.viewNazione=true;
                this.viewStato=false;
                this.theRecord['Stato'] = this.nazione;

            }
        }
        else
        {
            if(this.IndEstero==true)
            {
                this.stato='ESTERO';
            }
            this.viewStato=true;
            this.theRecord['Stato'] = this.stato;
        }
        

        console.log('connectedCallback indirizzo estero : ' + JSON.stringify(this.IndEstero));
        this.disableFieldByIndEstero();
        if(this.processtype !== undefined && this.processtype!= null && this.processtype!='' && this.processtype!=='Reclamo Scritto/Rich. Info' && !this.processtype.localeCompare('Venditori') === -1){
            console.log('Entering if with processtype >>> ' + this.processtype);
            this.disableAll=true;
            this.disableCodComuneSap=true;
            this.disableCap=true;
            this.disableCodViaSap=true;
            this.disableFlagVerificato=true;
            this.disableLocalita=true;
            this.disableProvincia=true;
            this.disableStato=true;
            
        }
        
    }


@api
    getInstanceWrapObject(servicepointretrieveddata){
        console.log('getInstanceWrapObject - START');
        console.log('getInstanceWrapObject - servicepointretrieveddata' +JSON.stringify(servicepointretrieveddata));
        getInstanceWrapAddressObject({s:servicepointretrieveddata}).then(data => {
            this.handleAddressValues(data);
            console.log('getInstanceWrapObject - getInstancewrapaddressobject Start '+ JSON.stringify(data));
            //this.wrapaddressobject = this.toObjectAddressInit(data);
            if(this.codcomunesap != null && this.codstradariosap != null && this.civico != null){
                this.disableVerifIndiButton = false;
            }
            else{
                this.disableVerifIndiButton = true;
            }
            console.log('getInstanceWrapObject - wrapaddressobject' + JSON.stringify(this.wrapaddressobject));
            //this.toObjectAddress();
            
        });
        
        console.log('getInstanceWrapObject - END');
    }


		
													 
	
    @api
    getInstanceWrapObjectBilling(billingProfileData){
        this.handleAddressValues(billingProfileData);
        this.theRecord = billingProfileData;
    }												 
											
	 

    /**
     * Get availability of verify address button
     */
    
    /*get verifyFieldsAddressDisabled(){
        console.log('verifyFieldsAddressDisabled - START ' + JSON.stringify(this.wrapaddressobject));
        let result = true;       
        

        if(
            (
                (this.submitedAddressFields.SupplyCountry__c != undefined
                && this.submitedAddressFields.SupplyCity__c != undefined
                && this.submitedAddressFields.SupplyPostalCode__c != undefined)
                &&
                (this.submitedAddressFields.SupplyCountry__c != ''
                && this.submitedAddressFields.SupplyCity__c != ''
                && this.submitedAddressFields.SupplyPostalCode__c != '')
            )
            || !this.verifyDisabledOnUpdate
        ){
            result = false;
        }
        
        return result;
    }*/
@api
    stampWrapObject(){
        console.log('wrapaddressobject in Stampwrapaddressobject*******************'+ this.wrapaddressobject);
    }

  @api  
     objectToMap(wrapaddressobject) {
        console.log('hdtTargetObjectAddressFields - objectToMap START');  
        let wrapObjectInput=[];
        console.log('arrivo qui');

        const ObjArray = Object.getOwnPropertyNames(wrapaddressobject);
        console.log('arrivo qui1');
        for(let i = 0; i < ObjArray.length; i++){
            console.log('entra nel for'+ ObjArray[i]);
           //inserting new key value pair inside map
           this.wrapObjectInput.set(ObjArray[i], obj[ObjArray[i]]);
        };
        console.log('hdtTargetObjectAddressFields - objectToMap END');
        return wrapObjectInput;
    }

    @api
     toObjectAddress(){
        console.log('hdtTargetObjectAddressFields - toObjectAddress START');
        this.fieldsAddressObject= this.wrapaddressobject;
        /*let fieldMap = this.objectToMap(this.wrapaddressobject);
        console.log(''+fieldMap.keys);
        fieldMap.forEach(element => {

                this.fieldsAddressObject.push(
                    {
                        fieldname: element,
                        required : false,
                        value: '',
                        disabled:  false
                    }
                ) 
        });*/
        console.log('hdtTargetObjectAddressFields - toObjectAddress END');

 }

 

    /**
     * Get address fields values
     * @param {*} event 
     */
    handleFieldsDataChange(event){
        this.disabledverifyFieldsAddressDisabled()
        console.log('hdtTargetObjectAddressFields - handleFieldsDataChange Start');
        this.submitedAddressFields[event.target.fieldName] = event.target.value;
        
        let evt = new CustomEvent("getaddressfields", {
            detail: this.submitedAddressFields
          });

        this.dispatchEvent(evt);

        if(this.selectedservicepoint != undefined){
            this.verifyDisabledOnUpdate = false;
            this.dispatchEvent(new CustomEvent("verifyaddressonupdate", {
                detail: this.verifyDisabledOnUpdate
              }));
        }

        this.hasAddressBeenVerified = false;
        this.dispatchEvent(new CustomEvent("addressverification", {
            detail: this.hasAddressBeenVerified
          }));

    }

    /**
     * Show errors for address fields
     * @param {*} fieldsWithError 
     */
    @api
    checkInvalidFields(fieldsWithError){
        for(var i=0; i<fieldsWithError.length; i++){
            
            let dataName = "[data-name='"+fieldsWithError[i]+"']";
            let dataField = this.template.querySelector(dataName);
            dataField.reportValidity();
        }
    }

    /**
     * Verify address
     */
    handleAddressVerification(){
        this.showSpinner = true;
        console.log('*** spinner '  +this.showSpinner );
        console.log('## this.codcomunesap: ' + this.codcomunesap + ' ##this.codstradariosap: ' +this.codstradariosap + ' ##this.civico: '+ this.civico );
        var city = this.codcomunesap;
        var istat = this.codstradariosap;
        city = city.replace(/\s/g, '');
        istat = istat.replace(/\s/g, '');
        getAddressRev({modality:'S',cityCode:city,streetCode:istat,houseNumCode:this.civico}).then(data =>
            {
                this.showSpinner = true;
                console.log("******:" + JSON.stringify(data));
                if(data['statusCode'] == 200 && data['prestazione'].length > 0){
                    console.log("Success:" + JSON.stringify(data));
                    this.comune = data['prestazione'][0].city1;
                    this.codcomunesap = data['prestazione'][0].cityCode;
                    this.codstradariosap = data['prestazione'][0].streetCode;
                    this.cap = data['prestazione'][0].postCode1;
                    this.via = data['prestazione'][0].street;
                    this.civico = data['prestazione'][0].houseNum1;
                    this.provincia = data['prestazione'][0].region;
                    
                    console.log('******PREVERIF:' + this.flagverificato);
                    this.flagverificato = true;
                    console.log('******POSTVERIF:' + this.flagverificato);

                    this.theRecord['Via']= data['prestazione'][0].street;
                    this.theRecord['Civico']= data['prestazione'][0].houseNum1;
                    this.theRecord['Comune']= data['prestazione'][0].city1;
                    this.theRecord['Provincia']= data['prestazione'][0].region;
                    this.theRecord['CAP']= data['prestazione'][0].postCode1;
                    this.theRecord['Codice Comune SAP']= data['prestazione'][0].cityCode;
                    this.theRecord['Codice Via Stradario SAP']= data['prestazione'][0].streetCode;
                    this.theRecord['Flag Verificato'] = true;
                    
                    this.disableConfirmButton = false;

                    this.dispEvent(true);
                    this.showSpinner = false;
                }
                else{
                    console.log("Error:" + JSON.stringify(data));
                    this.dispEvent(false);
                    this.showSpinner = false;
                    this.alert('Indirizzo da verificare','Attenzione! Indirizzo non censito sullo stradario SAP, inserisci una nuova Via','warn');
                }
                
    
    
        }); 
        if(this.theRecord['Stato']=='Italy'||this.theRecord['Stato']=='Italia'){
            this.theRecord['Stato']=='ITALIA';
            this.stato='ITALIA';
        }
        

      //  this.hasAddressBeenVerified = true;
        
       /* this.dispatchEvent(new CustomEvent("addressverification", {
            detail: this.hasAddressBeenVerified
          }));*/
    }
    dispEvent(param){
        const custEvent = new CustomEvent(
            'callpasstoparent', {
                detail: param 
            });
        this.dispatchEvent(custEvent);
    }
    
    handleKeyPress(event){
													  

        if(event.code=='Enter'){

        if(event.target.value.length == 2 && event.target.name == 'Comune' && event.keyCode === 13){

            //this.booleanForm= true;
            getAddressComune({city:event.target.value}).then(data =>
                {
                    
																  
                    if(data['statusCode'] == 200 && data['prestazione'].length > 0){
																				  
                        this.herokuAddressServiceData = data['prestazione'];
                        this.dispatchEvent(new CustomEvent('herokuaddress', {detail: this.herokuAddressServiceData}));
                        this.headertoshow = 'Comune';
                        
                        this.booleanForm=true;
                        this.template.querySelector('c-hdt-selection-address-response').openedForm();
                        this.template.querySelector('c-hdt-selection-address-response').valorizeTable(data['prestazione'],'Citta');
                    }
                    else{
                        let event2;
                        if(data['statusCode'] != 200){
                            event2 = new ShowToastEvent({
                                title: 'Errore',
                                variant: 'error',
                                message: "errore di connessione, riprovare o contattare l'amministratore"
                            });
                            
                        }
                        else{
                            event2 = new ShowToastEvent({
                                title: 'Errore',
                                variant: 'error',
                                message: 'Non sono presenti Comuni corrispondenti ai caratteri inseriti. Digitare nuovamente per effettuare una nuova ricerca.'
                            });
                        }
                        this.dispatchEvent(event2);
                    }
                    
        
        
            });

        }
        if((event.target.value.length >= 2 && event.target.value.length <=4)  && event.target.name == 'Via' && event.keyCode === 13){
										   
            getAddressInd({street:event.target.value,cityCode:this.codcomunesap}).then(data =>
                {
                    
																		  
                    if(data['statusCode'] == 200 && data['prestazione'].length > 0){
                        console.log("Sucessoooooooooooo:" + JSON.stringify(data));
                        this.herokuAddressServiceData = data['prestazione'];
                        this.headertoshow = 'Via';
                        this.booleanForm=false;
                        this.booleanForm=true;
    
                        this.template.querySelector('c-hdt-selection-address-response').openedForm2();
                        this.template.querySelector('c-hdt-selection-address-response').valorizeTable(data['prestazione'],'Via');
                    }
                    else{
                        let event2;
                        if(data['statusCode'] != 200){
                            event2 = new ShowToastEvent({
                                title: 'Errore',
                                variant: 'error',
                                message: "errore di connessione, riprovare o contattare l'amministratore"
                            });
                            
                        }
                        else{
                            event2 = new ShowToastEvent({
                                title: 'Errore',
                                variant: 'error',
                                message: 'Non sono presenti Indirizzi corrispondenti ai caratteri inseriti . Digitare nuovamente per effettuare una nuova ricerca.',
                            });
                        }
                        
                        this.dispatchEvent(event2);
                    }
                    
        
        
            });
        }
    } 
}  


}