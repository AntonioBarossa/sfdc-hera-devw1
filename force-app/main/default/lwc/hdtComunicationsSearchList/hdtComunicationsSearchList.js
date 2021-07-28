import { LightningElement, api } from 'lwc';
import getWsData from '@salesforce/apex/HDT_LC_ComunicationsSearchList.getWsData';
import sendFileToPrint from '@salesforce/apex/HDT_LC_ComunicationsSearchList.sendFileToPrint';
import { NavigationMixin } from 'lightning/navigation';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';

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

export default class HdtComunicationsSearchList extends NavigationMixin(LightningElement){

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
    url;
    fileName;
    showFile = false;
    blob;

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
        this.sendToApex(JSON.stringify(selected));
    }

    closeModal(event){
        console.log('# closeModal #');
        const closeEvent = new CustomEvent("closemodal", {
            detail: {booleanVar: 'showBillList'}
        });

        // Dispatches the event.
        this.dispatchEvent(closeEvent);
    }

    sendToApex(toPrint){
        console.log('# sendToApex #');
        sendFileToPrint({dataList: toPrint})
        .then(result => {
            console.log('# save success #');
            console.log('>>> resp: ' + result.success);
    
            var toastObj = {
                title: '',
                message: '',
                variant: ''
            };
    
            if(result.success){
                toastObj.title = 'Great Success!';
                toastObj.message = 'The selected record have been printed!';
                toastObj.variant = 'success';


                try{

                    var base64 = result.bodyBase64; 
                    var sliceSize = 512;
                    base64 = base64.replace(/^[^,]+,/, '');
                    base64 = base64.replace(/\s/g, '');
                    var byteCharacters = window.atob(base64);
                    var byteArrays = [];
        
                    for ( var offset = 0; offset < byteCharacters.length; offset = offset + sliceSize ) {
                        var slice = byteCharacters.slice(offset, offset + sliceSize);
                        var byteNumbers = new Array(slice.length);
                        for (var i = 0; i < slice.length; i++) {
                            byteNumbers[i] = slice.charCodeAt(i);
                        }
                        var byteArray = new Uint8Array(byteNumbers);
        
                        byteArrays.push(byteArray);
                    }
        
                    this.blob = new Blob(byteArrays, { type: 'application/pdf' });
                    //var data = new FormData();
                    //data.append("file", blob, "file");

                    const blobURL = URL.createObjectURL(this.blob);
                    //console.log('url-' + blobURL);
                    //window.open(blobURL);
                    this.url = blobURL;
                    this.fileName = 'myFileName.pdf';
                    this.showFile = true;

                    this[NavigationMixin.Navigate](
                        {
                            type: 'standard__webPage',
                            attributes: {
                                url: blobURL
                            }
                        }
                    );

                }catch(err){
                    console.log(err.message);
                }


            } else {
                toastObj.title = 'Something goes wrong!';
                toastObj.message = result.message;
                toastObj.variant = 'warning';
            }
        
            this.dispatchEvent(
                new ShowToastEvent({
                    title: toastObj.title,
                    message: toastObj.message,
                    variant: toastObj.variant
                }),
            );
    
        })
        .catch(error => {
            this.handleError(error);
        });
        
    }

    openFile(){
        console.log('# openFile #');
        this[NavigationMixin.Navigate](
            {
                type: 'standard__webPage',
                attributes: {
                    url: this.url
                }
            }
        );        
    }

    handleError(error){
        console.error('e.name => ' + error.name );
        console.error('e.message => ' + error.message);
        console.error('e.stack => ' + error.stack);
        this.dispatchEvent(
            new ShowToastEvent({
                title: error.name,
                message: error.message,
                variant: 'error',
                mode: 'sticky'
            })
        );
    }

    resetFile(){
        console.log('# resetFile #');
        this.blob = null;
        this.blobURL = URL.revokeObjectURL();
    }

}