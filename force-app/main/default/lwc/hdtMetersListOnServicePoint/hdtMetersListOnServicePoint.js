import { LightningElement, api } from 'lwc';
import getDatatableStructure from '@salesforce/apex/HDT_LC_MetersList.getDatatableStructure';
import getDataInContinuation from '@salesforce/apexContinuation/HDT_LC_MetersList.startRequest';

export default class HdtMetersListOnServicePoint extends LightningElement {

    @api recordId;
    spinner = true;
    error;
    errorMessage = '';
    columns = [];
    data = [];

    connectedCallback(){
        console.log('>>> recordId: ' + this.recordId);
        this.getDatatableStructure();
    }

    getDatatableStructure(){
        console.log('>>> getDatatableStructure');

        getDatatableStructure()
        .then(result => {
            console.log('>>> getDatatableStructure: success');
            this.error = false;
            //console.log(JSON.stringify(result));
            this.columns = result.columnList;
            this.getDataFromContinuation();
        })
        .catch(error => {
            console.log('>>> ERROR: ' + error.body.message);
            this.error = true;
            this.spinner = false;
            this.errorMessage = error.body.message;
        });
    }

    getDataFromContinuation(){
        console.log('>>> getDataFromContinuation');

        getDataInContinuation({recordId: this.recordId})
        .then(result => {
            console.log('>>> getDataFromContinuation: success');
            console.log(result);
            this.error = false;
            var parsedResult = JSON.parse(result);
            this.data = parsedResult.data;
            this.spinner = false;
        })
        .catch(error => {
            console.log('>>> ERROR: ' + error.body.message);
            this.error = true;
            this.spinner = false;
            this.errorMessage = error.body.message;
        });
    }

}