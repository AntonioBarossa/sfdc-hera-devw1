import { LightningElement, api, track, wire } from 'lwc';
import getMeterReadingRecords from '@salesforce/apex/HDT_LC_MeterReadingController.getMeterReadingRecords';

export default class HdtMeterReadingDetailTable extends LightningElement {

    @api columnsobj;
    @api contractNumber;
    @api loadData;
    @api hideCheckboxColumn;
    @track meterReadingData;
    @track detailTableHeader = 'Letture';
    meterReadingError = false;
    meterReadingErrorMessage = '';
    sortedBy;
    defaultSortDirection = 'asc';
    sortDirection = 'asc';

    connectedCallback(){
        console.log('HdtMeterReadingDetailTable loaded.');
    }

    @api loadingData(){
        this.loadData = false;
        this.meterReadingError = false;
        this.meterReadingErrorMessage = '';
    }

    @wire(getMeterReadingRecords, {contractCode : '$contractNumber'})
    wiredRecords({ error, data }) {
        if(data) {
            if(data.success){
                var obj = JSON.parse(data.data);
                this.meterReadingData = obj.data;
                //console.log(JSON.stringify(this.meterReadingData));
                this.detailTableHeader = 'Letture contratto > ' + this.contractNumber;
                this.loadData = true;
            } else {
                this.meterReadingError = true;
                this.meterReadingErrorMessage = data.message;
            }
            this.dataLoaded();
        } else if(error) {
            console.log('>>>> ERROR > getMeterReadingRecords');
            this.meterReadingError = true;
            this.meterReadingErrorMessage = 'ERROR';
        }
    }

    dataLoaded(){
        const dataLoad = new CustomEvent("dataload", {
            detail:  {spinner: false}
        });
        // Dispatches the event.
        this.dispatchEvent(dataLoad);
    }

    @api
    getSelectedReadingsValue() {
        var totalReadingValue = 0;
        var selectedRows = this.template.querySelector('lightning-datatable').getSelectedRows();
        selectedRows.forEach(row => {
            const readingValue = parseInt(row.posizioniPrecedentiLaVirgola);
            totalReadingValue += (isNaN(readingValue) ? 0 : readingValue);
        });

        return totalReadingValue;
    }

    @api
    getSelectedReadingsConcatenated() {
        var readingsString = '';
        var selectedRows = this.template.querySelector('lightning-datatable').getSelectedRows();
        selectedRows.forEach(row => {
            readingsString += row.tipoNumeratore + ': ' + row.posizioniPrecedentiLaVirgola + '\n';
        });

        return readingsString;
    }

    @api
    getSelectedReadingDate = () =>{
        let readingDate;
        let selectedRows = this.template.querySelector('lightning-datatable').getSelectedRows();
        return selectedRows[0].meterReadingData;
    }

    @api
    getSelectedReadingsList() {

        return this.template.querySelector('lightning-datatable').getSelectedRows();

    }

    sort(event){
        console.log('## sort ## ');

        try {
            const { fieldName: sortedBy, sortDirection } = event.detail;
            var sortField = event.detail.fieldName;
            //var sortDirection = event.detail.sortDirection;
            var listToConsider = 'meterReadingData';
            console.log('>>> sort by: ' + sortField + ' - sortDirection: ' + sortDirection);

            var currentObj = this.columnsobj.filter(c => { return c.fieldName == sortField });

            const cloneData = [...this.meterReadingData];

            switch (currentObj[0].fieldType) {
                case 'text':
                    if(sortDirection==='asc'){
                        cloneData.sort((a, b) => (a[sortField] > b[sortField]) ? 1 : -1);
                    } else {
                        cloneData.sort((a, b) => (a[sortField] < b[sortField]) ? 1 : -1);
                    }
                    break;
                case 'date':

                    cloneData.sort(function(a, b) {

                        var dateSplitted = b[sortField].split('/');
                        var data = dateSplitted[1] + '/' + dateSplitted[0] + '/' + dateSplitted[2];
                        
                        var dateSplitted2 = a[sortField].split('/');
                        var data2 = dateSplitted2[1] + '/' + dateSplitted2[0] + '/' + dateSplitted2[2];

                        if(sortDirection==='asc'){
                            return (new Date(data) < new Date(data2)) ? 1 : -1;
                        } else {
                            return (new Date(data) > new Date(data2)) ? 1 : -1;
                        }

                    });

                    break;
                case 'number':
                    if(sortDirection==='asc'){
                        cloneData.sort((a, b) => (parseFloat(a[sortField]) > parseFloat(b[sortField])) ? 1 : -1);
                    } else {
                        cloneData.sort((a, b) => (parseFloat(a[sortField]) < parseFloat(b[sortField])) ? 1 : -1);
                    }
            }

            this.meterReadingData = cloneData;
            this.sortDirection = sortDirection;
            this.sortedBy = sortedBy;

        } catch(e) {
            console.log(e);
        }
     
    }

    /*onHandleSort(event){
        console.log('## sort event ## ');

        try {
            const { fieldName: sortedBy, sortDirection } = event.detail;
            console.log('>>> sortDirection ' + sortDirection);
            const cloneData = [...this.meterReadingData];
            cloneData.sort(this.sortBy(sortedBy, sortDirection === 'asc' ? 1 : -1));
            this.meterReadingData = cloneData;

            this.sortDirection = sortDirection;
            this.sortedBy = sortedBy;

        } catch(e) {
            console.log(e);
        }
     
    }

    sortBy(field, reverse, primer) {
        const key = primer
            ? function(x) {
                  return primer(x[field]);
              }
            : function(x) {
                  return x[field];
              };

        return function(a, b) {
            a = key(a);
            b = key(b);
            return reverse * ((a > b) - (b > a));
        };
    }

    @api meterReadingBackendCall(contractNumber){
        console.log('>>>> contractNumber  > ' + contractNumber);
        this.loadData = false;
        getMeterReadingRecords({contractCode: contractNumber}).then(result => {

            if(result.success){
                this.meterReadingData = result.data;
                this.detailTableHeader = 'Letture contratto > ' + contractNumber;
                this.loadData = true;
            } else {
                console.log('>>>> ERROR > getMeterReadingRecords');
                this.meterReadingError = true;
                this.meterReadingErrorMessage = result.message;
            }

            const dataLoad = new CustomEvent("dataload", {
                detail:  {spinner: false}
            });
            // Dispatches the event.
            this.dispatchEvent(dataLoad);

        }).catch(error => {
            console.log('>>>> ERROR - catch');
            console.log(JSON.stringify(error));
        });
    }*/

}