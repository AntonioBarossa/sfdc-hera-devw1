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
            console.log('>>> getDataFromContinuation: success');
            console.log(result);
            this.error = false;
            var parsedResult = JSON.parse(result);
            this.data = parsedResult.data;

            /*
            this.data.push({assetNumber: '0000000000000001', materialDescription: 'Device Inforecord'});
            this.data.push({assetNumber: '0000000000000003', materialDescription: 'Device Inforecord'});
            this.data.push({assetNumber: '0000000000000004', materialDescription: 'Device Inforecord'});
            this.data.push({assetNumber: '0000000000000005', materialDescription: 'Device Inforecord'});
            this.data.push({assetNumber: '0000000000000006', materialDescription: 'Device Inforecord'});
            this.data.push({assetNumber: '0000000000000007', materialDescription: 'Device Inforecord'});
            this.data.push({assetNumber: '0000000000000008', materialDescription: 'Device Inforecord'});
            this.data.push({assetNumber: '0000000000000880', materialDescription: 'Device Inforecord'});
            this.data.push({assetNumber: '0000000000000888', materialDescription: 'Device Inforecord'});
            this.data.push({assetNumber: '0000000000000555', materialDescription: 'Device Inforecord'});
            this.data.push({assetNumber: '0000000000000044', materialDescription: 'Device Inforecord'});
            this.data.push({assetNumber: '0000000000000333', materialDescription: 'Device Inforecord'});
            this.data.push({assetNumber: '0000000000000222', materialDescription: 'Device Inforecord'});
            this.data.push({assetNumber: '0000000000000999', materialDescription: 'Device Inforecord'});
            */

            this.totalResult = parsedResult.data.length;
            console.log('>>> this.data.length ' + this.data.length);

            this.title = 'Elenco Misuratori (' + this.totalResult.toString() + ')';

            if(this.totalResult > 10){
                this.tableHeightCss = 'full-table';
            } else {
                this.tableHeightCss = 'short-table';
            }

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