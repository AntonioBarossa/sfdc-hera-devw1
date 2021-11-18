import { LightningElement, api, track } from 'lwc';
import getDatatableStructure from '@salesforce/apex/HDT_LC_MetersList.getDatatableStructure';
import getDataInContinuation from '@salesforce/apexContinuation/HDT_LC_MetersList.startRequest';

export default class HdtMetersListOnServicePoint extends LightningElement {

    @api recordId;
    spinner = true;
    error;
    errorMessage = '';
    totalResult = 0;
    columns = [];
    data = [];
    tableHeightCss;
    title = 'Elenco Misuratori';

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

            console.log('>>> getDataFromContinuation:');
            console.log(result);
            this.error = false;
            var parsedResult = JSON.parse(result);
            console.log('>>> result: ' + parsedResult.status);

            switch (parsedResult.status) {

                case 'success':
                    this.data = parsedResult.data;
                    this.totalResult = parsedResult.data.length;
                    console.log('>>> this.data.length ' + this.data.length);
        
                    this.title = 'Elenco Misuratori (' + this.totalResult.toString() + ')';
        
                    if(this.totalResult > 10){
                        this.tableHeightCss = 'full-table';
                    } else {
                        this.tableHeightCss = 'short-table';
                    }

                    break;

                case 'failed':
                    this.error = true;
                    this.errorMessage = parsedResult.errorDetails[0].message;

            }

            this.spinner = false;
        })
        .catch(error => {
            
            this.error = true;
            this.spinner = false;
            this.errorMessage = 'Errore durante la ricezione dei dati o nelle credenziali di accesso';
            console.warn(error.body.message);
        });
    }

}