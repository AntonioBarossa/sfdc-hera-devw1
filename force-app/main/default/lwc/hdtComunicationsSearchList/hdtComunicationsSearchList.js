import { LightningElement, api } from 'lwc';
import getWsData from '@salesforce/apex/HDT_LC_ComunicationsSearchList.getWsData';

const billsColumns = [
    { label: 'Numero bolletta', fieldName: 'billNumber' },
    { label: 'Data registrazione', fieldName: 'billDate'}
];

const rateColumns = [
    { label: 'Id Plico', fieldName: 'billNumber' },
    { label: 'Data registrazione', fieldName: 'billDate'}
];

const sollecitiColumns = [
    { label: 'Id Plico', fieldName: 'billNumber' },
    { label: 'Data registrazione', fieldName: 'billDate'}
];

export default class HdtComunicationsSearchList extends LightningElement {

    @api parameters;
    @api customerCode;
    @api otherParams;
    modalHeader;
    error = {
        show: false,
        message: ''
    }
    spinner = true;

    data = [];
    columns;
    muleRequest = {
        documentCategory: '',
        customerAccount: '',
        startDate: '',
        endDate: ''
    };
    recordValue;

    connectedCallback(){
        console.log('>>> otherParams ' + JSON.stringify(this.otherParams));

        var objParameters = JSON.parse(this.parameters);
        this.modalHeader = objParameters.header;

        this.muleRequest.customerAccount = this.customerCode;

        for(var i in this.otherParams){
            this.muleRequest[i] = this.otherParams[i];
        }

        switch (objParameters.type) {
            case 'bills':
                this.columns = billsColumns;
                break;
            case 'rate':
                //billingProfile
                this.muleRequest.documentCategory = 'Comunicazioni';
                this.columns = rateColumns;
                break;
            case 'solleciti':
                this.muleRequest.documentCategory = 'Solleciti';
                this.columns = sollecitiColumns;
        }

        this.getDataFromWs();
    }

    getDataFromWs(){
        var muleRequestString = JSON.stringify(this.muleRequest);
        getWsData({wrapperObj: muleRequestString})
        .then(result => {
            //console.log(result);
            var resultObj = JSON.parse(result);
            if(resultObj.success){
                var dataObj = JSON.parse(resultObj.body);
                this.data = dataObj;
                this.spinner = false;
            } else {
                this.error.show = true;
                this.error.message = resultObj.message; 
                this.spinner = false;
            }
            

        }).catch(error => {
            this.error.show = true;
            this.error.message = 'CATCH ERROR MESSAGE';
        });
    }

    onChangeHandler(event){
        console.log('>>> set ' + event.currentTarget.name + ' = ' + event.detail.value);
        this.muleRequest[event.currentTarget.name] = event.detail.value;
    }

    interrogation(event){
        try{
            this.spinner = true;
            this.data = [];
            this.getDataFromWs();
        } catch(ex){
            console.log(ex);
        }
    }

    //getSelectedRow(event) {
    //    const selectedRow = event.detail.selectedRows;
    //    console.log('>>> SELECTION: ' + selectedRow[0].billNumber);
    //    this.recordValue = selectedRow[0].billNumber;
    //}

    apply(event){
        var el = this.template.querySelector('lightning-datatable');
        var selected = el.getSelectedRows();
        console.log('>>> I WANT PDF ABOUT > ' + JSON.stringify(selected));
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