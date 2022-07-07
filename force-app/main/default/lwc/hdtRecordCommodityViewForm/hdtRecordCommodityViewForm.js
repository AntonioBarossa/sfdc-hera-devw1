import { LightningElement, track, wire, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getFields from '@salesforce/apex/HDT_LC_RecordCommodityViewForm.getFields';

export default class HdtRecordCommodityViewForm extends LightningElement {

    @api processType;
    @api recordId='5001w000009vifkAAA';
    @api objectName;
    @api density;
    @api showReadOnly;

    @track errorMessage;
    @track error;
    @track fieldsJSON;
    @track wiredResponse;
    @track firstColumn = [];
    @track secondColumn = [];
    @track showViewSection = false;

    // // Test di Visualizzazione -> DA TOGLIERE !!!
    // greeting = 'Si Visualizza!';
    // changeHandler(event) {
    //     // console.log('### Object Name ' + this.objectName);
    //     // console.log('### RecordId ' + this.recordId);
    //     // console.log('### RecordType ' + this.recordType);
    //     this.greeting = event.target.value;
    // }



    @wire(getFields, { processType: '$processType' }) 
        wiredFieldsJSON ({ error, data }) {
            if (data) {
                console.log('### Struttura Form ' + JSON.stringify(data));
                console.log('### Object Name ' + this.objectName);
                console.log('### RecordId ' + this.recordId);
                console.log('### RecordType ' + this.recordType);
                this.wiredResponse = JSON.parse(data);
                // this.validateClass = this.wiredResponse[0].ValidateClass__c;
                if(this.wiredResponse[0].hasOwnProperty("FieldsJSON__c")){
                    this.fieldsJSON = JSON.parse(this.wiredResponse[0].FieldsJSON__c);
                    this.fieldsJSON.forEach(obj => {
                        if(obj.Column == 1){
                            this.firstColumn.push(obj);
                        }else{
                            this.secondColumn.push(obj);
                        }
                    });
                    this.showViewSection = true;
                }
            } else if (error) {
                this.error = true;
                this.errorMessage = error;
                // this.errorMessage = error.message;
            }
        }

        connectedCallback(){
            console.log('### START connected');
            console.log('### ProcessType -> ' + this.processType);
            console.log('### END Connected ###');
            
        }


} 