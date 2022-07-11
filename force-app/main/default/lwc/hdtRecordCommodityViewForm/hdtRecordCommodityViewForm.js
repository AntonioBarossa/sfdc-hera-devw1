import { LightningElement, track, wire, api } from 'lwc';
// import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getFields from '@salesforce/apex/HDT_LC_RecordCommodityViewForm.getFields';

export default class HdtRecordCommodityViewForm extends LightningElement {

    @api processType; // = 'Comunicazione Pagamento';
    @api recordId;
    @api objectApiName; // ='Case';
    @api density;
    @api showReadOnly;

    @track errorMessage;
    @track error;
    @track fieldsJSON;
    @track wiredResponse;
    @track firstColumn = [];
    @track secondColumn = [];
    @track showViewSection = false;

    @track fieldsJSONReadOnly;
    @track firstColumnReadOnly = [];
    @track secondColumnReadOnly = [];
    @track fields = [];
    columnList = [];
    fieldList = [];

    // // @wire(getFields, { processType: '$processType' }) 
    // @wire(getFields, { recordId: '$recordId' }) 
    //     wiredFieldsJSON ({ error, data }) {
    //         if (data) {
    //             console.log('### Struttura Form ' + JSON.stringify(data));
    //             console.log('### Object Name ' + this.objectName);
    //             console.log('### RecordId ' + this.recordId);
    //             // console.log('### RecordType ' + this.recordType);
    //             this.wiredResponse = JSON.parse(data);
    //             // this.validateClass = this.wiredResponse[0].ValidateClass__c;

    //             if(this.wiredResponse[0].hasOwnProperty("FieldsJSON__c")){ // restituisce un valore booleano che indica se l'oggetto su cui lo stai chiamando ha una proprietà con il nome dell'argomento
    //                 this.fieldsJSON = JSON.parse(this.wiredResponse[0].FieldsJSON__c);
    //                 this.fieldsJSON.forEach(obj => {
    //                     if(obj.Column == 1){
    //                         this.firstColumn.push(obj);
    //                     }else{
    //                         this.secondColumn.push(obj);
    //                     }
    //                 });
    //                 this.showViewSection = true;
    //             }
                
    //         } else if (error) {
    //             this.error = true;
    //             this.errorMessage = error;
    //             // this.errorMessage = error.message;
    //         }
    //     }

        // connectedCallback(){
        //     console.log('### START connected');
            
        //     console.log('### ProcessType -> ' + this.processType);
        //     console.log('### RecordId -> ' + this.recordId);
        //     console.log('### Object Name -> ' + this.objectApiName);
        //     console.log('### END Connected ###');
        // }

        connectedCallback()
        {
            console.log('### START connected 2');
            getFields({ recordId: this.recordId })
            .then(result => {
                console.log('result:'+ result);
                if (result) {
                    let parsedResult = JSON.parse(result);
                    // console.log('parsedResult:'+ parsedResult);
                    this.columnList = parsedResult.split(",");
                    // console.log('columnList:'+ this.columnList[0]);
                    // this.columnList2 = this.columnList.split(":");
                    for(let i=0; i<this.columnList.length; i++ ){
                        if(this.columnList[i].includes("FieldName")){
                            // this.columnList2=[...this.columnList[i]];
                            let campo = [];
                            campo = this.columnList[i].split(":");
                            this.fields.push(campo[1]);
                        }
                    }
                    for(let i=0; i<this.fields.length; i++){
                        console.log('fields:'+ this.fields[i]);
                    }
                    
                    // this.parsedResult.forEach(obj => {
                    //     // if(obj.FieldsJSON__c == "FieldName"){
                    //     //     this.fieldList[0].push(obj.FieldsJSON__c);
                    //     // });
                    // }
                    // this.fields = fieldList;
                    // this.error = undefined;
                    // console.log('### fields -> ' + this.fields);
                }
            }) .catch(error => {
                console.log(error);
                this.error = error;
            }); 

            // console.log('### result -> ' + this.result);
            // console.log('### ProcessType 2 -> ' + this.processType);
            console.log('### RecordId 2 -> ' + this.recordId);
            console.log('### Object Name 2 -> ' + this.objectApiName);
            console.log('### END Connected 2 ###');
        }

        // handleLoad(event) {
        //     console.log(event.type);
        //     console.log(event.detail);
        // }
}