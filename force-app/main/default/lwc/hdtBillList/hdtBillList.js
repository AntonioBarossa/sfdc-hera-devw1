import { LightningElement, api } from 'lwc';
import getWsData from '@salesforce/apex/HDT_LC_BillList.getWsData';

const columns = [
    { label: 'Numero bolletta', fieldName: 'billNumber' },
    { label: 'Data registrazione', fieldName: 'billDate'}
];

export default class HdtBillList extends LightningElement {

    @api parameters;
    modalHeader;
    error = {
        show: false,
        message: ''
    }

    data = [];
    columns = columns;

    connectedCallback(){
        var objParameters = JSON.parse(this.parameters);
        this.modalHeader = objParameters.header;
        this.getDataFromWs();
    }

    getDataFromWs(){
        getWsData({wrapperObj: ''})
        .then(result => {
            console.log(result);
            var resultObj = JSON.parse(result);
            if(resultObj.success){
                var dataObj = JSON.parse(resultObj.body);
                this.data = dataObj;
            } else {
                this.error.show = true;
                this.error.message = resultObj.message; 
            }
            

        }).catch(error => {
            this.error.show = true;
            this.error.message = 'CATCH ERROR MESSAGE';
        });
    }

    apply(event){

    }

    closeModal(event){
        console.log('# closeModal #');
        const closeEvent = new CustomEvent("closemodal", {
            detail: {booleanVar: 'showBillList'}
        });

        // Dispatches the event.
        this.dispatchEvent(closeEvent);
    }
}