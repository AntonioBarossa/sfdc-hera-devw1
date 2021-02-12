import { LightningElement, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class hdtChildOrderProcessDetails extends LightningElement {
    @api order;
    title = '';
    isVisible = false;
    loading = false;
    moduleButtonVisibility = false;
    moduleButtonLabel = 'Modulo informativo';
    isAccountResidential;
    choosenSection = '';
    activeSections = [];

    handleModuleButtonVisibility(){
        if (this.order !== undefined &&
            (this.order.RecordType.DeveloperName === 'HDT_RT_Subentro' || this.order.RecordType.DeveloperName === 'HDT_RT_Attivazione')
            && this.order.ServicePoint__r.RecordType.DeveloperName === 'HDT_RT_Gas') {
            this.moduleButtonVisibility = true;
        }
    };

    handleModuleButtonLabel(){
        if (this.order !== undefined 
            &&  this.order.ServicePoint__r.MeterClass__c === 'G10 Pareti def.') {
            this.moduleButtonLabel = 'Modulo B12';
        }
    }

    typeVisibility(type){
        let result = true;

        if(this.order !== undefined ){
            switch (type) {
                case 'ele':
                    result = this.order.ServicePoint__r.RecordType.DeveloperName === 'HDT_RT_Ele';
                    break;
                case 'gas':
                    result = this.order.ServicePoint__r.RecordType.DeveloperName === 'HDT_RT_Gas';
                    break
                default:
                    result = true;
                    break;
            }
        }
        return result;
    }

    processVisibility(process){
        let result = true;

        if(this.order.RecordType.DeveloperName !== undefined ){
            switch (process) {
                case 'ele':
                    result = this.order.RecordType.DeveloperName === 'HDT_RT_Ele';
                    break;
                case 'gas':
                    result = this.order.RecordType.DeveloperName === 'HDT_RT_Gas';
                    break
                default:
                    result = true;
                    break;
            }
        }
        return result;
    }

    fields = {};

    applyCreditCheckLogic(fieldName){
        if(this.order.RecordType.DeveloperName !== undefined ){
            switch (this.order.RecordType.DeveloperName) {
                case 'HDT_RT_Subentro':
                    if (fieldName === 'IncomingCreditCheck__c') {
                        return 'OK';
                    }
                    else if (fieldName === 'OutgoingCreditCheckResult__c') {
                        return 'OK';
                    }
                    break;
                case 'HDT_RT_Attivazione':
                    if (fieldName === 'IncomingCreditCheck__c') {
                        return 'OK';
                    }
                    break;
                default:
                    break;
            }
            
        }
    }

    getFirstStepName(){
        const availableStep = this.fields.filter(section => section.processVisibility === true);
        return availableStep[0].name;
    }

    handleNext(event){
        console.log('handle Click Event Data: ', event.currentTarget.value);
        this.choosenSection = event.currentTarget.value;
        this.activeSections = [this.choosenSection];
    }
    handleSectionToggle(event) {
        this.activeSections = [this.choosenSection];
        // this.activeSections = event.detail.openSections;
    }
    handlePrevious(event){
        this.choosenSection = event.currentTarget.value;
        this.activeSections = [this.choosenSection];
    }

    handleFields(){
        this.fields = [
            {
                step: 3,
                label: 'Cliente Uscente',
                name: 'clienteUscente',
                objectApiName: 'Account',
                recordId: this.order.ServicePoint__r.Account__c,
                processVisibility: 
                    (this.order.ServicePoint__r.Account__c !== this.order.AccountId) 
                    && (this.order.RecordType.DeveloperName === 'HDT_RT_Subentro' || this.order.RecordType.DeveloperName === 'HDT_RT_SwitchIn'),
                data: [
                    {
                        'label': 'Nome',
                        'apiname': 'FirstName__c',
                        'typeVisibility': this.order.Account.RecordType.DeveloperName === 'HDT_RT_Residenziale',
                        'required': false,
                        'disabled': true,
                        'value': '',
                        'processVisibility': ''
                    },
                    {
                        'label': 'Cognome',
                        'apiname': 'LastName__c',
                        'typeVisibility': this.order.Account.RecordType.DeveloperName === 'HDT_RT_Residenziale',
                        'required': false,
                        'disabled': true,
                        'value': '',
                        'processVisibility': ''
                    },
                    {
                        'label': 'Codice Fiscale',
                        'apiname': 'FiscalCode__c',
                        'typeVisibility': this.order.Account.RecordType.DeveloperName === 'HDT_RT_Residenziale',
                        'required': false,
                        'disabled': true,
                        'value': '',
                        'processVisibility': ''
                    },
                    {
                        'label': 'Partita IVA',
                        'apiname': 'VATNumber__c',
                        'typeVisibility': this.order.Account.RecordType.DeveloperName === 'HDT_RT_Business',
                        'required': false,
                        'disabled': true,
                        'value': '',
                        'processVisibility': ''
                    },
                    {
                        'label': 'Ragione sociale',
                        'apiname': 'Name',
                        'typeVisibility': this.order.Account.RecordType.DeveloperName === 'HDT_RT_Business',
                        'required': false,
                        'disabled': true,
                        'value': '',
                        'processVisibility': ''
                    }
                ]
            },
            {
                step: 4,
                label: 'Credit check',
                name: 'creditCheck',
                objectApiName: 'Order',
                recordId: this.order.Id,
                processVisibility: this.order.RecordType.DeveloperName === 'HDT_RT_Subentro' 
                || this.order.RecordType.DeveloperName === 'HDT_RT_Attivazione'
                || this.order.RecordType.DeveloperName === 'HDT_RT_AttivazioneConModifica'
                || this.order.RecordType.DeveloperName === 'HDT_RT_SwitchIn',
                data: [
                    {
                        'label': 'Esito credit Check Entrante',
                        'apiname': 'IncomingCreditCheck__c',
                        'typeVisibility': this.typeVisibility('both'),
                        'required': false,
                        'disabled': true,
                        'value': this.applyCreditCheckLogic('IncomingCreditCheck__c'),
                        'processVisibility': ''
                    },
                    {
                        'label': 'Esito credit Check Uscente',
                        'apiname': 'OutgoingCreditCheckResult__c',
                        'typeVisibility': this.typeVisibility('both'),
                        'required': false,
                        'disabled': true,
                        'value': this.applyCreditCheckLogic('OutgoingCreditCheckResult__c'),
                        'processVisibility': ''
                    },
                    {
                        'label': 'Descrizione esito',
                        'apiname': 'CreditCheckDescription__c',
                        'typeVisibility': this.typeVisibility('both'),
                        'required': false,
                        'disabled': true,
                        'value': '',
                        'processVisibility': ''
                    }
                ]
            },
            {
                step: 5,
                label: 'Dettaglio impianto',
                name: 'dettaglioImpianto',
                objectApiName: 'ServicePoint__c',
                recordId: this.order.ServicePoint__c,
                processVisibility: this.order.RecordType.DeveloperName === 'HDT_RT_Subentro'
                || this.order.RecordType.DeveloperName === 'HDT_RT_Attivazione'
                || this.order.RecordType.DeveloperName === 'HDT_RT_AttivazioneConModifica'
                || this.order.RecordType.DeveloperName === 'HDT_RT_SwitchIn',
               data: [
                {
                    'label': 'POD/PdR',
                    'apiname': 'ServicePointCode__c',
                    'typeVisibility': this.typeVisibility('both'),
                    'required': true,
                    'disabled': true,
                    'value': '',
                    'processVisibility': ''
                },
                {
                    'label': 'Disalimentabilità',
                    'apiname': 'Disconnectable__c',
                    'typeVisibility': this.typeVisibility('both'),
                    'required': true,
                    'disabled': false,
                    'value': '',
                    'processVisibility': ''
                },
                {
                    'label': 'Categoria disalimentabilità',
                    'apiname': 'DisconnectibilityType__c',
                    'typeVisibility': this.typeVisibility('both'),
                    'required': true,
                    'disabled': false,
                    'value': '',
                    'processVisibility': ''
                },
                {
                    'label': 'Tipo Impianto',
                    'apiname': 'ImplantType__c',
                    'typeVisibility': this.typeVisibility('ele'),
                    'required': true,
                    'disabled': false,
                    'value': '',
                    'processVisibility': ''
                },
                {
                    'label': 'Potenza disponibile',
                    'apiname': 'PowerAvailable__c',
                    'typeVisibility': this.typeVisibility('ele'),
                    'required': false,
                    'disabled': false,
                    'value': '',
                    'processVisibility': ''
                },
                {
                    'label': 'Potenza impegnata',
                    'apiname': 'PowerContractual__c',
                    'typeVisibility': this.typeVisibility('ele'),
                    'required': false,
                    'disabled': false,
                    'value': '',
                    'processVisibility': ''
                },
                {
                    'label': 'Tensione',
                    'apiname': 'VoltageLevel__c',
                    'typeVisibility': this.typeVisibility('ele'),
                    'required': true,
                    'disabled': false,
                    'value': '',
                    'processVisibility': ''
                },
                {
                    'label': 'Uso energia',
                    'apiname': 'undefined1',
                    'typeVisibility': this.typeVisibility('ele'),
                    'required': true,
                    'disabled': false,
                    'value': '',
                    'processVisibility': ''
                },
                {
                    'label': 'Distributore',
                    'apiname': 'Distributor__c',
                    'typeVisibility': this.typeVisibility('both'),
                    'required': true,
                    'disabled': true,
                    'value': '',
                    'processVisibility': ''
                },
                {
                    'label': 'Recapito telefonico',
                    'apiname': 'DisconnectibilityPhone__c',
                    'typeVisibility': this.typeVisibility('both'),
                    'required': true,
                    'disabled': true,
                    'value': '',
                    'processVisibility': ''
                },
                {
                    'label': 'Provenienza',
                    'apiname': 'MarketOrigin__c',
                    'typeVisibility': this.typeVisibility('both'),
                    'required': true,
                    'disabled': true,
                    'value': '',
                    'processVisibility': ''
                },
                {
                    'label': 'Categoria uso',
                    'apiname': 'UseCategory__c',
                    'typeVisibility': this.typeVisibility('gas'),
                    'required': true,
                    'disabled': true,
                    'value': '',
                    'processVisibility': ''
                },
                {
                    'label': 'Classe prelievo',
                    'apiname': 'WithdrawalClass__c',
                    'typeVisibility': this.typeVisibility('gas'),
                    'required': true,
                    'disabled': false,
                    'value': '',
                    'processVisibility': ''
                },
                {
                    'label': 'Classe Contatore',
                    'apiname': 'MeterClass__c',
                    'typeVisibility': this.typeVisibility('gas'),
                    'required': true,
                    'disabled': false,
                    'value': '',
                    'processVisibility': ''
                },
                {
                    'label': 'Potenzialità massima richiesta',
                    'apiname': 'MaxRequiredPotential__c',
                    'typeVisibility': this.typeVisibility('gas'),
                    'required': true,
                    'disabled': false,
                    'value': '',
                    'processVisibility': ''
                },
                {
                    'label': 'Misuratore',
                    'apiname': 'MeterSN__c',
                    'typeVisibility': this.typeVisibility('ele'),
                    'required': false,
                    'disabled': true,
                    'value': '',
                    'processVisibility': ''
                },
                {
                    'label': 'Tipo Mercato',
                    'apiname': 'CommoditySector__c',
                    'typeVisibility': this.typeVisibility('both'),
                    'required': true,
                    'disabled': true,
                    'value': '',
                    'processVisibility': ''
                },
                {
                    'label': 'Consumi Anno',
                    'apiname': 'AnnualConsumption__c',
                    'typeVisibility': this.typeVisibility('both'),
                    'required': true,
                    'disabled': true,
                    'value': '',
                    'processVisibility': ''
                },
                {
                    'label': 'Residente all\'indirizzo di Fornitura',
                    'apiname': 'Resident__c',
                    'typeVisibility': this.typeVisibility('both'),
                    'required': true,
                    'disabled': true,
                    'value': '',
                    'processVisibility': ''
                },
                {
                    'label': 'Località/Codice REMI',
                    'apiname': 'RemiCode__c',
                    'typeVisibility': this.typeVisibility('gas'),
                    'required': true,
                    'disabled': true,
                    'value': '',
                    'processVisibility': ''
                },
                {
                    'label': 'Tipo di connessione',
                    'apiname': 'SupplyType__c',
                    'typeVisibility': this.typeVisibility('ele'),
                    'required': true,
                    'disabled': true,
                    'value': '',
                    'processVisibility': ''
                }
               ]
            },
            {
                step: 6,
                label: 'Indirizzo fornitura',
                name: 'indirizzoFornitura',
                objectApiName: 'ServicePoint__c',
                recordId: this.order.ServicePoint__c,
                processVisibility: this.order.RecordType.DeveloperName === 'HDT_RT_Subentro' 
                || this.order.RecordType.DeveloperName === 'HDT_RT_Attivazione'
                || this.order.RecordType.DeveloperName === 'HDT_RT_AttivazioneConModifica'
                || this.order.RecordType.DeveloperName === 'HDT_RT_SwitchIn',
                data: [
                    {
                        'label': 'Comune',
                        'apiname': 'SupplyCity__c',
                        'typeVisibility': this.typeVisibility('both'),
                        'required': true,
                        'disabled': true,
                        'value': '',
                        'processVisibility': ''
                    },
                    {
                        'label': 'Via',
                        'apiname': 'SupplyStreet__c',
                        'typeVisibility': this.typeVisibility('both'),
                        'required': true,
                        'disabled': true,
                        'value': '',
                        'processVisibility': ''
                    },
                    {
                        'label': 'Civico',
                        'apiname': 'SupplyStreetNumber__c',
                        'typeVisibility': this.typeVisibility('both'),
                        'required': true,
                        'disabled': true,
                        'value': '',
                        'processVisibility': ''
                    },
                    {
                        'label': 'Localita',
                        'apiname': 'SupplyPlace__c',
                        'typeVisibility': this.typeVisibility('both'),
                        'required': true,
                        'disabled': true,
                        'value': '',
                        'processVisibility': ''
                    },
                    {
                        'label': 'Provincia',
                        'apiname': 'SupplyProvince__c',
                        'typeVisibility': this.typeVisibility('both'),
                        'required': true,
                        'disabled': true,
                        'value': '',
                        'processVisibility': ''
                    },
                    {
                        'label': 'Cap',
                        'apiname': 'SupplyPostalCode__c',
                        'typeVisibility': this.typeVisibility('both'),
                        'required': true,
                        'disabled': true,
                        'value': '',
                        'processVisibility': ''
                    },
                    {
                        'label': 'Nazione',
                        'apiname': 'SupplyCountry__c',
                        'typeVisibility': this.typeVisibility('both'),
                        'required': true,
                        'disabled': true,
                        'value': '',
                        'processVisibility': ''
                    },
                    {
                        'label': 'Codice Istat',
                        'apiname': 'undefined3',
                        'typeVisibility': this.typeVisibility('both'),
                        'required': true,
                        'disabled': true,
                        'value': '',
                        'processVisibility': ''
                    }
                ]
            },
            {
                step: 7,
                label: this.order.Account.RecordType.DeveloperName === 'HDT_RT_Residenziale' ? 'Indirizzo di residenza' : 'Indirizzo sede legale',
                name: 'indirizzoResidenzaOsedeLegale',
                objectApiName: 'Account',
                recordId: this.order.AccountId,
                processVisibility: this.order.RecordType.DeveloperName === 'HDT_RT_Subentro' 
                || this.order.RecordType.DeveloperName === 'HDT_RT_Attivazione'
                || this.order.RecordType.DeveloperName === 'HDT_RT_AttivazioneConModifica'
                || this.order.RecordType.DeveloperName === 'HDT_RT_SwitchIn',
                data: [
                    {
                        'label': 'Comune',
                        'apiname': 'BillingCity',
                        'typeVisibility': this.typeVisibility('both'),
                        'required': true,
                        'disabled': true,
                        'value': '',
                        'processVisibility': ''
                    },
                    {
                        'label': 'Via',
                        'apiname': 'BillingStreetName__c',
                        'typeVisibility': this.typeVisibility('both'),
                        'required': true,
                        'disabled': true,
                        'value': '',
                        'processVisibility': ''
                    },
                    {
                        'label': 'Civico',
                        'apiname': 'BillingStreetNumber__c',
                        'typeVisibility': this.typeVisibility('both'),
                        'required': true,
                        'disabled': true,
                        'value': '',
                        'processVisibility': ''
                    },
                    {
                        'label': 'Localita',
                        'apiname': 'BillingPlace__c',
                        'typeVisibility': this.typeVisibility('both'),
                        'required': true,
                        'disabled': true,
                        'value': '',
                        'processVisibility': ''
                    },
                    {
                        'label': 'Provincia',
                        'apiname': 'BillingState',
                        'typeVisibility': this.typeVisibility('both'),
                        'required': true,
                        'disabled': true,
                        'value': '',
                        'processVisibility': ''
                    },
                    {
                        'label': 'Cap',
                        'apiname': 'BillingPostalCode',
                        'typeVisibility': this.typeVisibility('both'),
                        'required': true,
                        'disabled': true,
                        'value': '',
                        'processVisibility': ''
                    },
                    {
                        'label': 'Nazione',
                        'apiname': 'BillingCountry',
                        'typeVisibility': this.typeVisibility('both'),
                        'required': true,
                        'disabled': true,
                        'value': '',
                        'processVisibility': ''
                    },
                    {
                        'label': 'Codice Istat',
                        'apiname': 'BillingCityCode__c',
                        'typeVisibility': this.typeVisibility('both'),
                        'required': true,
                        'disabled': true,
                        'value': '',
                        'processVisibility': ''
                    }
                ]
            },
            {
                step: 8,
                label:'Fatturazione',
                name: 'fatturazione',
                objectApiName: 'BillingProfile__c',
                recordId: this.order.BillingProfile__c,
                processVisibility: this.order.RecordType.DeveloperName === 'HDT_RT_Subentro' 
                || this.order.RecordType.DeveloperName === 'HDT_RT_Attivazione'
                || this.order.RecordType.DeveloperName === 'HDT_RT_AttivazioneConModifica'
                || this.order.RecordType.DeveloperName === 'HDT_RT_SwitchIn',
                data: [
                    {
                        'label': 'Modalità Invio Bolletta',
                        'apiname': 'BillSendingMethod__c',
                        'typeVisibility': this.typeVisibility('both'),
                        'required': true,
                        'disabled': true,
                        'value': '',
                        'processVisibility': ''
                    },
                    {
                        'label': 'Email Invio Bolletta',
                        'apiname': 'InvoiceEmailAddress__c',
                        'typeVisibility': this.typeVisibility('both'),
                        'required': false,
                        'disabled': true,
                        'value': '',
                        'processVisibility': ''
                    },
                    {
                        'label': 'Email PEC invio Bolletta',
                        'apiname': 'InvoiceCertifiedEmailAddress__c',
                        'typeVisibility': this.typeVisibility('both'),
                        'required': false,
                        'disabled': true,
                        'value': '',
                        'processVisibility': ''
                    },
                    {
                        'label': 'Destinatario Divergente',
                        'apiname': 'DivergentSubject__c',
                        'typeVisibility': this.typeVisibility('both'),
                        'required': false,
                        'disabled': true,
                        'value': '',
                        'processVisibility': ''
                    },
                    {
                        'label': 'Comune',
                        'apiname': 'InvoicingCity__c',
                        'typeVisibility': this.typeVisibility('both'),
                        'required': true,
                        'disabled': true,
                        'value': '',
                        'processVisibility': ''
                    },
                    {
                        'label': 'Stato ',
                        'apiname': 'InvoicingCountry__c',
                        'typeVisibility': this.typeVisibility('both'),
                        'required': true,
                        'disabled': true,
                        'value': '',
                        'processVisibility': ''
                    },
                    {
                        'label': 'Provincia',
                        'apiname': 'InvoicingProvince__c',
                        'typeVisibility': this.typeVisibility('both'),
                        'required': true,
                        'disabled': true,
                        'value': '',
                        'processVisibility': ''
                    },
                    {
                        'label': 'Nome Via',
                        'apiname': 'InvoicingStreetName__c',
                        'typeVisibility': this.typeVisibility('both'),
                        'required': true,
                        'disabled': true,
                        'value': '',
                        'processVisibility': ''
                    },
                    {
                        'label': 'Civico',
                        'apiname': 'InvoicingStreetNumber__c',
                        'typeVisibility': this.typeVisibility('both'),
                        'required': true,
                        'disabled': true,
                        'value': '',
                        'processVisibility': ''
                    },
                    {
                        'label': 'CAP',
                        'apiname': 'InvoicingPostalCode__c',
                        'typeVisibility': this.typeVisibility('both'),
                        'required': true,
                        'disabled': true,
                        'value': '',
                        'processVisibility': ''
                    },
                    {
                        'label': 'Codice ISTAT',
                        'apiname': 'InvoicingCityCode__c',
                        'typeVisibility': this.typeVisibility('both'),
                        'required': true,
                        'disabled': true,
                        'value': '',
                        'processVisibility': ''
                    }
                ]
            },
            {
                step: 9,
                label: 'Fatturazione elettronica',
                name: 'fatturazioneElettronicaClienteNonResidenziale',
                objectApiName: 'Order',
                recordId: this.order.Id,
                processVisibility: (this.order.RecordType.DeveloperName === 'HDT_RT_Subentro' 
                || this.order.RecordType.DeveloperName === 'HDT_RT_Attivazione'
                || this.order.RecordType.DeveloperName === 'HDT_RT_AttivazioneConModifica'
                || this.order.RecordType.DeveloperName === 'HDT_RT_SwitchIn')
                && this.order.Account.RecordType.DeveloperName === 'HDT_RT_Business',
                data:[
                    {
                        'label': 'Codice Destinatario',
                        'apiname': 'SubjectCode__c',
                        'typeVisibility': this.typeVisibility('both'),
                        'required': false,
                        'disabled': true,
                        'value': '',
                        'processVisibility': ''
                    },
                    {
                        'label': 'PEC Fatturazione Elettronica',
                        'apiname': 'InvoiceCertifiedEmailAddress__c',
                        'typeVisibility': this.typeVisibility('both'),
                        'required': false,
                        'disabled': true,
                        'value': '',
                        'processVisibility': ''
                    },
                    {
                        'label': 'Modalità invio Fatturazione',
                        'apiname': 'ElectronicInvoicingMethod__c',
                        'typeVisibility': this.typeVisibility('both'),
                        'required': false,
                        'disabled': true,
                        'value': '',
                        'processVisibility': ''
                    },
                    {
                        'label': 'Tipo invio fattura XML',
                        'apiname': 'XMLType__c',
                        'typeVisibility': this.typeVisibility('both'),
                        'required': false,
                        'disabled': true,
                        'value': '',
                        'processVisibility': ''
                    },
                    {
                        'label': 'CIG',
                        'apiname': 'CIG__c',
                        'typeVisibility': this.typeVisibility('both'),
                        'required': false,
                        'disabled': true,
                        'value': '',
                        'processVisibility': ''
                    },
                    {
                        'label': 'CUP',
                        'apiname': 'CUP__c',
                        'typeVisibility': this.typeVisibility('both'),
                        'required': false,
                        'disabled': true,
                        'value': '',
                        'processVisibility': ''
                    }
                ]
            },
            {
                step: 10,
                label: 'Metodo pagamento',
                name: 'metodoPagamento',
                objectApiName: 'BillingProfile__c',
                recordId: this.order.BillingProfile__c,
                processVisibility: this.order.RecordType.DeveloperName === 'HDT_RT_Subentro' 
                || this.order.RecordType.DeveloperName === 'HDT_RT_Attivazione'
                || this.order.RecordType.DeveloperName === 'HDT_RT_AttivazioneConModifica'
                || this.order.RecordType.DeveloperName === 'HDT_RT_SwitchIn',
                data: [
                    {
                        'label': 'Modalità di Pagamento',
                        'apiname': 'PaymentMethod__c',
                        'typeVisibility': this.typeVisibility('both'),
                        'required': true,
                        'disabled': true,
                        'value': '',
                        'processVisibility': ''
                    },
                    {
                        'label': 'IBAN Estero',
                        'apiname': 'IbanIsForeign__c',
                        'typeVisibility': this.typeVisibility('both'),
                        'required': false,
                        'disabled': true,
                        'value': '',
                        'processVisibility': ''
                    },
                    {
                        'label': 'Numeri di Controllo',
                        'apiname': 'IbanCIN_IBAN__c',
                        'typeVisibility': this.typeVisibility('both'),
                        'required': false,
                        'disabled': true,
                        'value': '',
                        'processVisibility': ''
                    },
                    {
                        'label': 'CIN',
                        'apiname': 'IbanCIN__c',
                        'typeVisibility': this.typeVisibility('both'),
                        'required': false,
                        'disabled': true,
                        'value': '',
                        'processVisibility': ''
                    },
                    {
                        'label': 'ABI',
                        'apiname': 'IbanABI__c',
                        'typeVisibility': this.typeVisibility('both'),
                        'required': false,
                        'disabled': true,
                        'value': '',
                        'processVisibility': ''
                    },
                    {
                        'label': 'CAB',
                        'apiname': 'IbanCAB__c',
                        'typeVisibility': this.typeVisibility('both'),
                        'required': false,
                        'disabled': true,
                        'value': '',
                        'processVisibility': ''
                    },
                    {
                        'label': 'Numero conto corrente',
                        'apiname': 'IbanCodeNumber__c',
                        'typeVisibility': this.typeVisibility('both'),
                        'required': false,
                        'disabled': true,
                        'value': '',
                        'processVisibility': ''
                    },
                    {
                        'label': 'Tipologia Intestatario',
                        'apiname': 'SignatoryType__c',
                        'typeVisibility': this.typeVisibility('both'),
                        'required': false,
                        'disabled': true,
                        'value': '',
                        'processVisibility': ''
                    },
                    {
                        'label': 'Codice Fiscale intestatario c/c',
                        'apiname': 'BankAccountSignatoryFiscalCode__c',
                        'typeVisibility': this.typeVisibility('both'),
                        'required': false,
                        'disabled': true,
                        'value': '',
                        'processVisibility': ''
                    },
                    {
                        'label': 'Nome Intestatario c/c',
                        'apiname': 'BankAccountSignatoryFirstName__c',
                        'typeVisibility': this.typeVisibility('both'),
                        'required': false,
                        'disabled': true,
                        'value': '',
                        'processVisibility': ''
                    },
                    {
                        'label': 'Cognome Intestario c/c',
                        'apiname': 'BankAccountSignatoryLastName__c',
                        'typeVisibility': this.typeVisibility('both'),
                        'required': false,
                        'disabled': true,
                        'value': '',
                        'processVisibility': ''
                    },
                    {
                        'label': 'Contact di riferimento',
                        'apiname': 'undefined8',
                        'typeVisibility': this.typeVisibility('both'),
                        'required': false,
                        'disabled': true,
                        'value': '',
                        'processVisibility': ''
                    }
                ]
            },
            {
                step: 11,
                label: 'Metodo firma canale invio',
                name: 'metodoFirmaCanaleInvio',
                objectApiName: 'Order',
                recordId: this.order.Id,
                processVisibility: this.order.RecordType.DeveloperName === 'HDT_RT_Subentro' 
                || this.order.RecordType.DeveloperName === 'HDT_RT_Attivazione'
                || this.order.RecordType.DeveloperName === 'HDT_RT_AttivazioneConModifica'
                || this.order.RecordType.DeveloperName === 'HDT_RT_SwitchIn',
                data: [
                    {
                        'label': 'Metodo firma',
                        'apiname': 'SignatureMethod__c',
                        'typeVisibility': this.typeVisibility('both'),
                        'required': true,
                        'disabled': true,
                        'value': '',
                        'processVisibility': ''
                    },
                    {
                        'label': 'Invio doc',
                        'apiname': 'DocSendingMethod__c',
                        'typeVisibility': this.typeVisibility('both'),
                        'required': true,
                        'disabled': true,
                        'value': '',
                        'processVisibility': ''
                    }
                ]
            }
        ];
    }

    connectedCallback(){
        console.log('isAccountResidential: ', this.order.Account.RecordType.DeveloperName === 'HDT_RT_Residenziale' ? 'Indirizzo di residenza' : 'Indirizzo sede legale');
        console.log('hdtChildOrderProcessDetails: ', JSON.parse(JSON.stringify(this.order)));
        this.title = 'Processo di ' + this.order.RecordType.Name;
        this.isAccountResidential = this.order.Account.RecordType.DeveloperName === 'HDT_RT_Residenziale';
        this.handleModuleButtonVisibility();
        this.handleModuleButtonLabel();
        this.handleFields();
        this.applyCreditCheckLogic();
        this.choosenSection = this.getFirstStepName();
        this.activeSections = [this.getFirstStepName()];
    }
}