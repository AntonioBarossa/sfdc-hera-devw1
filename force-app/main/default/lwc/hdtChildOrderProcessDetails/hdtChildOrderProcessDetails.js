import { LightningElement, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import initFields from '@salesforce/apex/HDT_LC_ChildOrderProcessDetails.initFields';

export default class hdtChildOrderProcessDetails extends LightningElement {
    @api order;
    title = '';
    isVisible = false;
    loading = false;

    typeVisibility(type){
        let result = true;

        switch (type) {
            case 'ele':
                result = this.order.ServicePoint__c.RecordType.DeveloperName === 'HDT_RT_Ele';
                break;
            case 'gas':
                result = this.order.ServicePoint__c.RecordType.DeveloperName === 'HDT_RT_Gas';
                break
            default:
                result = true;
                break;
        }

        return result;
    }

    fields = {};

    handleInitFields(){
        this.loading = true;
        initFields().then(data =>{
            this.loading = false;
            console.log('handleInitFields: ',JSON.parse(JSON.stringify(data)));
            this.fields = data;
        }).catch(error => {
            this.loaded = true;
            console.log(error.body.message);
            const toastErrorMessage = new ShowToastEvent({
                title: 'Errore',
                message: error.body.message,
                variant: 'error',
                mode: 'sticky'
            });
            this.dispatchEvent(toastErrorMessage);
        });
    }

    connectedCallback(){
        console.log('hdtChildOrderProcessDetails: ', JSON.parse(JSON.stringify(this.order)));
        this.isVisible = this.order.RecordType.DeveloperName !== 'HDT_RT_Default' ? true : false;
        this.title = 'Processo di ' + this.order.RecordType.Name;

        this.fields = {
            creditCheck: {
                data: [
                    {
                        'label': 'Esito credit Check Entrante',
                        'apiname': 'IncomingCreditCheck__c',
                        // 'typeVisibility': this.typeVisibility('both'),
                        'required': false,
                        'disabled': true
                    },
                    {
                        'label': 'Esito credit Check Uscente',
                        'apiname': 'OutgoingCreditCheckResult__c',
                        // 'typeVisibility': this.typeVisibility('both'),
                        'required': false,
                        'disabled': true
                    },
                    {
                        'label': 'Descrizione esito',
                        'apiname': 'CreditCheckDescription__c',
                        // 'typeVisibility': this.typeVisibility('both'),
                        'required': false,
                        'disabled': true
                    }
                ]
            },
            dettaglioCommodity: {
               data: [
                {
                    'label': 'POD/PdR',
                    'apiname': 'ServicePointCode__c',
                    // 'typeVisibility': this.typeVisibility('both'),
                    'required': true,
                    'disabled': true
                },
                {
                    'label': 'Disalimentabilità',
                    'apiname': 'Disconnectable__c',
                    // 'typeVisibility': this.typeVisibility('both'),
                    'required': true,
                    'disabled': false
                },
                {
                    'label': 'Categoria disalimentabilità',
                    'apiname': 'DisconnectibilityType__c',
                    // 'typeVisibility': this.typeVisibility('both'),
                    'required': true,
                    'disabled': false
                },
                {
                    'label': 'Tipo Impianto',
                    'apiname': 'ImplantType__c',
                    // 'typeVisibility': this.typeVisibility('ele'),
                    'required': true,
                    'disabled': false
                },
                {
                    'label': 'Potenza disponibile',
                    'apiname': 'PowerAvailable__c',
                    // 'typeVisibility': this.typeVisibility('ele'),
                    'required': false,
                    'disabled': false
                },
                {
                    'label': 'Potenza impegnata',
                    'apiname': 'PowerContractual__c',
                    // 'typeVisibility': this.typeVisibility('ele'),
                    'required': false,
                    'disabled': false
                },
                {
                    'label': 'Tensione',
                    'apiname': 'VoltageLevel__c',
                    // 'typeVisibility': this.typeVisibility('ele'),
                    'required': true,
                    'disabled': false
                },
                {
                    'label': 'Uso energia',
                    'apiname': 'undefined1',
                    // 'typeVisibility': this.typeVisibility('ele'),
                    'required': true,
                    'disabled': false
                },
                {
                    'label': 'Distributore',
                    'apiname': 'Distributor__c',
                    // 'typeVisibility': this.typeVisibility('both'),
                    'required': true,
                    'disabled': true
                },
                {
                    'label': 'Recapito telefonico',
                    'apiname': 'DisconnectibilityPhone__c',
                    // 'typeVisibility': this.typeVisibility('both'),
                    'required': true,
                    'disabled': true
                },
                {
                    'label': 'Provenienza',
                    'apiname': 'MarketOrigin__c',
                    // 'typeVisibility': this.typeVisibility('both'),
                    'required': true,
                    'disabled': true
                },
                {
                    'label': 'Categoria uso',
                    'apiname': 'UseCategory__c',
                    // 'typeVisibility': this.typeVisibility('gas'),
                    'required': true,
                    'disabled': true
                },
                {
                    'label': 'Classe prelievo',
                    'apiname': 'WithdrawalClass__c',
                    // 'typeVisibility': this.typeVisibility('gas'),
                    'required': true,
                    'disabled': false
                },
                {
                    'label': 'Classe Contatore',
                    'apiname': 'MeterClass__c',
                    // 'typeVisibility': this.typeVisibility('gas'),
                    'required': true,
                    'disabled': false
                },
                {
                    'label': 'Potenzialità massima richiesta',
                    'apiname': 'undefined2',
                    // 'typeVisibility': this.typeVisibility('gas'),
                    'required': true,
                    'disabled': false
                },
                {
                    'label': 'Misuratore',
                    'apiname': 'MeterSN__c',
                    // 'typeVisibility': this.typeVisibility('ele'),
                    'required': false,
                    'disabled': true
                },
                {
                    'label': 'Tipo Mercato',
                    'apiname': 'CommoditySector__c',
                    // 'typeVisibility': this.typeVisibility('both'),
                    'required': true,
                    'disabled': true
                },
                {
                    'label': 'Consumi Anno',
                    'apiname': 'AnnualConsumption__c',
                    // 'typeVisibility': this.typeVisibility('both'),
                    'required': true,
                    'disabled': true
                },
                {
                    'label': 'Residente all\'indirizzo di Fornitura',
                    'apiname': 'Resident__c',
                    // 'typeVisibility': this.typeVisibility('both'),
                    'required': true,
                    'disabled': true
                },
                {
                    'label': 'Località/Codice REMI',
                    'apiname': 'RemiCode__c',
                    // 'typeVisibility': this.typeVisibility('gas'),
                    'required': true,
                    'disabled': true
                },
                {
                    'label': 'Tipo di connessione',
                    'apiname': 'SupplyType__c',
                    // 'typeVisibility': this.typeVisibility('ele'),
                    'required': true,
                    'disabled': true
                }
               ]
            },
            indirizzoFornitura: {
                data: [
                    {
                        'label': 'Comune',
                        'apiname': 'SupplyCity__c',
                        // 'typeVisibility': this.typeVisibility('both'),
                        'required': true,
                        'disabled': true
                    },
                    {
                        'label': 'Via',
                        'apiname': 'SupplyStreet__c',
                        // 'typeVisibility': this.typeVisibility('both'),
                        'required': true,
                        'disabled': true
                    },
                    {
                        'label': 'Civico',
                        'apiname': 'SupplyStreetNumber__c',
                        // 'typeVisibility': this.typeVisibility('both'),
                        'required': true,
                        'disabled': true
                    },
                    {
                        'label': 'Localita',
                        'apiname': 'SupplyPlace__c',
                        // 'typeVisibility': this.typeVisibility('both'),
                        'required': true,
                        'disabled': true
                    },
                    {
                        'label': 'Provincia',
                        'apiname': 'SupplyProvince__c',
                        // 'typeVisibility': this.typeVisibility('both'),
                        'required': true,
                        'disabled': true
                    },
                    {
                        'label': 'Cap',
                        'apiname': 'SupplyPostalCode__c',
                        // 'typeVisibility': this.typeVisibility('both'),
                        'required': true,
                        'disabled': true
                    },
                    {
                        'label': 'Nazione',
                        'apiname': 'SupplyCountry__c',
                        // 'typeVisibility': this.typeVisibility('both'),
                        'required': true,
                        'disabled': true
                    },
                    {
                        'label': 'Codice Istat',
                        'apiname': 'undefined3',
                        // 'typeVisibility': this.typeVisibility('both'),
                        'required': true,
                        'disabled': true
                    }
                ]
            },
            indirizzoResidenza: {
                data: [
                    {
                        'label': 'Comune',
                        'apiname': 'ShippingCity',
                        // 'typeVisibility': this.typeVisibility('both'),
                        'required': true,
                        'disabled': true
                    },
                    {
                        'label': 'Via',
                        'apiname': 'ShippingStreet',
                        // 'typeVisibility': this.typeVisibility('both'),
                        'required': true,
                        'disabled': true
                    },
                    {
                        'label': 'Civico',
                        'apiname': 'ShippingStreetNumber__c',
                        // 'typeVisibility': this.typeVisibility('both'),
                        'required': true,
                        'disabled': true
                    },
                    {
                        'label': 'Localita',
                        'apiname': 'ShippingPlace__c',
                        // 'typeVisibility': this.typeVisibility('both'),
                        'required': true,
                        'disabled': true
                    },
                    {
                        'label': 'Provincia',
                        'apiname': 'ShippingProvince__c',
                        // 'typeVisibility': this.typeVisibility('both'),
                        'required': true,
                        'disabled': true
                    },
                    {
                        'label': 'Cap',
                        'apiname': 'ShippingPostalCode',
                        // 'typeVisibility': this.typeVisibility('both'),
                        'required': true,
                        'disabled': true
                    },
                    {
                        'label': 'Nazione',
                        'apiname': 'ShippingState',
                        // 'typeVisibility': this.typeVisibility('both'),
                        'required': true,
                        'disabled': true
                    },
                    {
                        'label': 'Codice Istat',
                        'apiname': 'undefined4',
                        // 'typeVisibility': this.typeVisibility('both'),
                        'required': true,
                        'disabled': true
                    }
                ]
            },
            indirizzoSedeLegale: {
                data: [
                    {
                        'label': 'Comune',
                        'apiname': 'ShippingCity',
                        // 'typeVisibility': this.typeVisibility('both'),
                        'required': true,
                        'disabled': true
                    },
                    {
                        'label': 'Via',
                        'apiname': 'ShippingStreet',
                        // 'typeVisibility': this.typeVisibility('both'),
                        'required': true,
                        'disabled': true
                    },
                    {
                        'label': 'Civico',
                        'apiname': 'ShippingStreetNumber__c',
                        // 'typeVisibility': this.typeVisibility('both'),
                        'required': true,
                        'disabled': true
                    },
                    {
                        'label': 'Localita',
                        'apiname': 'ShippingPlace__c',
                        // 'typeVisibility': this.typeVisibility('both'),
                        'required': true,
                        'disabled': true
                    },
                    {
                        'label': 'Provincia',
                        'apiname': 'ShippingProvince__c',
                        // 'typeVisibility': this.typeVisibility('both'),
                        'required': true,
                        'disabled': true
                    },
                    {
                        'label': 'Cap',
                        'apiname': 'ShippingPostalCode',
                        // 'typeVisibility': this.typeVisibility('both'),
                        'required': true,
                        'disabled': true
                    },
                    {
                        'label': 'Nazione',
                        'apiname': 'ShippingState',
                        // 'typeVisibility': this.typeVisibility('both'),
                        'required': true,
                        'disabled': true
                    },
                    {
                        'label': 'Codice Istat',
                        'apiname': 'undefined5',
                        // 'typeVisibility': this.typeVisibility('both'),
                        'required': true,
                        'disabled': true
                    }
                ]
            },
            fatturazione: {
                data: [
                    {
                        'label': 'Modalità Invio Bolletta',
                        'apiname': 'BillSendingMethod__c',
                        // 'typeVisibility': this.typeVisibility('both'),
                        'required': true,
                        'disabled': true
                    },
                    {
                        'label': 'Email Invio Bolletta',
                        'apiname': 'InvoiceEmailAddress__c',
                        // 'typeVisibility': this.typeVisibility('both'),
                        'required': false,
                        'disabled': true
                    },
                    {
                        'label': 'Email PEC invio Bolletta',
                        'apiname': 'InvoiceCertifiedEmailAddress__c',
                        // 'typeVisibility': this.typeVisibility('both'),
                        'required': false,
                        'disabled': true
                    },
                    {
                        'label': 'Destinatario Divergente',
                        'apiname': 'DivergentSubject__c',
                        // 'typeVisibility': this.typeVisibility('both'),
                        'required': false,
                        'disabled': true
                    },
                    {
                        'label': 'Comune',
                        'apiname': 'undefined6',
                        // 'typeVisibility': this.typeVisibility('both'),
                        'required': true,
                        'disabled': true
                    },
                    {
                        'label': 'Stato ',
                        'apiname': 'InvoicingCountry__c',
                        // 'typeVisibility': this.typeVisibility('both'),
                        'required': true,
                        'disabled': true
                    },
                    {
                        'label': 'Provincia',
                        'apiname': 'InvoicingProvince__c',
                        // 'typeVisibility': this.typeVisibility('both'),
                        'required': true,
                        'disabled': true
                    },
                    {
                        'label': 'Nome Via',
                        'apiname': 'InvoicingStreetName__c',
                        // 'typeVisibility': this.typeVisibility('both'),
                        'required': true,
                        'disabled': true
                    },
                    {
                        'label': 'Civico',
                        'apiname': 'InvoicingStreetNumber__c',
                        // 'typeVisibility': this.typeVisibility('both'),
                        'required': true,
                        'disabled': true
                    },
                    {
                        'label': 'CAP',
                        'apiname': 'InvoicingPostalCode__c',
                        // 'typeVisibility': this.typeVisibility('both'),
                        'required': true,
                        'disabled': true
                    },
                    {
                        'label': 'Codice ISTAT',
                        'apiname': 'InvoicingCityCode__c',
                        // 'typeVisibility': this.typeVisibility('both'),
                        'required': true,
                        'disabled': true
                    }
                ]
            },
            fatturazioneElettronicaClienteNonResidenziale: {
                data:[
                    {
                        'label': 'Codice Destinatario',
                        'apiname': 'SubjectCode__c',
                        // 'typeVisibility': this.typeVisibility('both'),
                        'required': false,
                        'disabled': true
                    },
                    {
                        'label': 'PEC Fatturazione Elettronica',
                        'apiname': 'InvoiceCertifiedEmailAddress__c',
                        // 'typeVisibility': this.typeVisibility('both'),
                        'required': false,
                        'disabled': true
                    },
                    {
                        'label': 'Modalità invio Fatturazione',
                        'apiname': 'ElectronicInvoicingMethod__c',
                        // 'typeVisibility': this.typeVisibility('both'),
                        'required': false,
                        'disabled': true
                    },
                    {
                        'label': 'Tipo invio fattura XML',
                        'apiname': 'XMLType__c',
                        // 'typeVisibility': this.typeVisibility('both'),
                        'required': false,
                        'disabled': true
                    },
                    {
                        'label': 'CIG',
                        'apiname': 'CIG__c',
                        // 'typeVisibility': this.typeVisibility('both'),
                        'required': false,
                        'disabled': true
                    },
                    {
                        'label': 'CUP',
                        'apiname': 'CUP__c',
                        // 'typeVisibility': this.typeVisibility('both'),
                        'required': false,
                        'disabled': true
                    }
                ]
            },
            metodoPagamento: {
                data: [
                    {
                        'label': 'Modalità di Pagamento',
                        'apiname': 'PaymentMethod__c',
                        // 'typeVisibility': this.typeVisibility('both'),
                        'required': true,
                        'disabled': true
                    },
                    {
                        'label': 'IBAN Estero',
                        'apiname': 'IbanIsForeign__c',
                        // 'typeVisibility': this.typeVisibility('both'),
                        'required': false,
                        'disabled': true
                    },
                    {
                        'label': 'Numeri di Controllo',
                        'apiname': 'IbanCIN_IBAN__c',
                        // 'typeVisibility': this.typeVisibility('both'),
                        'required': false,
                        'disabled': true
                    },
                    {
                        'label': 'CIN',
                        'apiname': 'IbanCIN__c',
                        // 'typeVisibility': this.typeVisibility('both'),
                        'required': false,
                        'disabled': true
                    },
                    {
                        'label': 'ABI',
                        'apiname': 'IbanABI__c',
                        // 'typeVisibility': this.typeVisibility('both'),
                        'required': false,
                        'disabled': true
                    },
                    {
                        'label': 'CAB',
                        'apiname': 'IbanCAB__c',
                        // 'typeVisibility': this.typeVisibility('both'),
                        'required': false,
                        'disabled': true
                    },
                    {
                        'label': 'Numero conto corrente',
                        'apiname': 'IbanCodeNumber__c',
                        // 'typeVisibility': this.typeVisibility('both'),
                        'required': false,
                        'disabled': true
                    },
                    {
                        'label': 'Tipologia Intestatario',
                        'apiname': 'SignatoryType__c',
                        // 'typeVisibility': this.typeVisibility('both'),
                        'required': false,
                        'disabled': true
                    },
                    {
                        'label': 'Codice Fiscale intestatario c/c',
                        'apiname': 'BankAccountSignatoryFiscalCode__c',
                        // 'typeVisibility': this.typeVisibility('both'),
                        'required': false,
                        'disabled': true
                    },
                    {
                        'label': 'Nome Intestatario c/c',
                        'apiname': 'BankAccountSignatoryFirstName__c',
                        // 'typeVisibility': this.typeVisibility('both'),
                        'required': false,
                        'disabled': true
                    },
                    {
                        'label': 'Cognome Intestario c/c',
                        'apiname': 'BankAccountSignatoryLastName__c',
                        // 'typeVisibility': this.typeVisibility('both'),
                        'required': false,
                        'disabled': true
                    },
                    {
                        'label': 'Contact di riferimento',
                        'apiname': 'undefined8',
                        // 'typeVisibility': this.typeVisibility('both'),
                        'required': false,
                        'disabled': true
                    },
                    {
                        'label': 'ID Billing profile',
                        'apiname': 'Id',
                        // 'typeVisibility': this.typeVisibility('both'),
                        'required': false,
                        'disabled': true
                    }
                ]
            },
            metodoFirmaCanaleInvio: {
                data: [
                    {
                        'label': 'Metodo firma',
                        'apiname': 'SignatureMethod__c',
                        // 'typeVisibility': this.typeVisibility('both'),
                        'required': true,
                        'disabled': true
                    },
                    {
                        'label': 'Invio doc',
                        'apiname': 'DocSendingMethod__c',
                        // 'typeVisibility': this.typeVisibility('both'),
                        'required': true,
                        'disabled': true
                    }
                ]
            }
        };
    }
}