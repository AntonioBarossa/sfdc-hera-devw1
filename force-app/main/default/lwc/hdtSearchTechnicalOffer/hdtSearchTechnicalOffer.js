import { LightningElement, track } from 'lwc';

const columns = [
    { label: 'Definizione', fieldName: 'definition' },
    { label: 'Ins.Utente', fieldName: 'checkUser'},
    { label: 'Tariffa', fieldName: 'amount'},
    { label: 'GR Info', fieldName: 'grInfo'},
    { label: 'Prezzo', fieldName: 'price'},
    { label: 'Sconto', fieldName: 'discount' },
    { label: 'Valore', fieldName: 'value'},
    { label: 'Stringa', fieldName: 'stringValue'},
    { label: 'Nome Tecn.', fieldName: 'tecName'}   
];

const offertData = [
        {
            id: '1',
            definition: 'EE Valore PRZ indice data att',
            checkUser: false,
            amount: '',
            grInfo: '',
            price: '',
            discount: '',
            value: '',
            stringValue: '',
            tecName: 'EFP_CT_MI'
        },
        {
            id: '2',
            definition: 'EE Percentuale Adeg. Indice',
            checkUser: false,
            amount: '',
            grInfo: '',
            price: '',
            discount: '',
            value: '',
            stringValue: '',
            tecName: 'ES_ADG_CT'
        },
        {
            id: '3',
            definition: 'EE Prezzo personalizzato Mono',
            checkUser: true,
            amount: 'value1',
            grInfo: 'value2',
            price: 'value3',
            discount: 'value4',
            value: 'value5',
            stringValue: 'value6',
            tecName: 'EP_PERS_MO'
        }          

];

export default class HdtSearchTechnicalOffer extends LightningElement {
    data = [];
    columns = columns;

    @track item = {
        selectedId: '',
        name: '',
        code: ''
    }

    @track selid;
    @track selectRecordName;

    @track spinnerObj = {
        spinner: false,
        spincss: ''
    };

    @track searchObj = {
        offertName: '',
        version: '',
        offertCode: ''
    }

    setOffertName(event){
        console.log('### setOffertName ###');
        this.searchObj.offertName = event.target.value;
    }

    setVersion(event){
        console.log('### setVersion ###');
        this.searchObj.version = event.target.value;
    }

    setOffertCode(event){
        console.log('### setOffertCode ###');
        this.searchObj.offertCode = event.target.value;
    }

    searchClick(event){
        console.log('### searchClick ###');
        this.spinnerObj.spinner = true;
        this.spinnerObj.spincss = 'loadingdata slds-text-heading_small';
        console.log('### search these fields -> ' + this.searchObj.offertName);
        console.log('### search these fields -> ' + this.searchObj.version);
        console.log('### search these fields -> ' + this.searchObj.offertCode);
        
        setTimeout(() => {
            this.data = offertData;
            this.spinnerObj.spinner = false;
        }, 3000);

    }

    cloneData(event){
        console.log('### cloneData ###');
        this.spinnerObj.spinner = true;
        this.spinnerObj.spincss = 'savingdata slds-text-heading_small';
        
        setTimeout(() => {
            this.spinnerObj.spinner = false;
        }, 3000);
        
    }

    closeSearch(event){
        console.log('### closeSearch ###');
        this.searchObj.offertName = '';
        this.searchObj.version = '';
        this.searchObj.offertCode = '';
        const closesearchEvent = new CustomEvent("closesearch", {
            detail:  ''
        });

        // Dispatches the event.
        this.dispatchEvent(closesearchEvent);
    }

    handleSelection(event){
        console.log('# handleSelection #');
        console.log('# -> ' + event.detail.selectedId);
        console.log('# -> ' + event.detail.code);
        console.log('# -> ' + event.detail.selectedObj);
        this.item.selectedId = event.detail.selectedId;
        this.item.name = event.detail.code;
        this.item.code = event.detail.selectedObj;
    }
}
