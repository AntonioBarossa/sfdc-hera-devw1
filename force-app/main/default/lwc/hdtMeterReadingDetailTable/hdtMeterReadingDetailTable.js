import { LightningElement, api, track, wire } from 'lwc';
import getMeterReadingRecords from '@salesforce/apex/HDT_LC_MeterReadingController.getMeterReadingRecords';
import getConfigurationDetailTable from '@salesforce/apex/HDT_LC_MeterReadingController.getConfigurationDetailTable';

export default class HdtMeterReadingDetailTable extends LightningElement {

    columnsobj;
    @api contractNumber;
    @api loadData;
    @api hideCheckboxColumn;
    @api nonStandAlone;
    @api maxRows;
    @api showModality;
    @api contractService;
    showChooseType = false;
    @track meterReadingData;
    @track detailTableHeader = 'Letture';
    tempList = [
        {label: 'DEFAULT', name: 'DEFAULT', iconName: 'utility:topic', desc: 'Imposta il valore "default"'},
        {label: 'FULL', name: 'FULL', iconName: 'utility:wellness', desc: 'Imposta il valore "full"'}
    ];
    meterReadingError = false;
    meterReadingErrorMessage = '';
    sortedBy;
    defaultSortDirection = 'asc';
    sortDirection = 'asc';
    modality = 'DEFAULT';

    connectedCallback(){
        console.log('HdtMeterReadingDetailTable loaded.');
        console.log('>>> use new service -> ' + this.showModality);
        console.log('>>> contractService -> ' + this.contractService);
        this.configurationData();
    }

    configurationData(){
        getConfigurationDetailTable({contractService: this.contractService})
        .then(result => {

            if(result.success){
                this.columnsobj = JSON.parse(result.meterReadingTable);
                this.showModality = result.trbEnable;
                this.detailBackendCall();
            } else {
                console.log('>>>> ERROR > getContractRecords');
                this.error = true;
                this.errorMessage = result.message;
                this.spinner = false;                
            }

        }).catch(error => {
            console.log('>>>> ERROR - catch');
            console.log(error);
        });
    }

    detailBackendCall(){

        getMeterReadingRecords({contractCode : this.contractNumber, modality: this.modality, contractService: this.contractService})
        .then(result => {

            if(result) {
                if(result.success){
                    var obj = JSON.parse(result.data);
                    this.meterReadingData = obj.data;

                    console.log('>>> data: ' + JSON.stringify(this.meterReadingData));

                    this.detailTableHeader = 'Letture contratto > ' + this.contractNumber;
                    this.loadData = true;

                } else {
                    console.log('>>> result error');
                    this.meterReadingError = true;
                    this.meterReadingErrorMessage = result.message;
                }
                //this.dataLoaded();
            }

        }).catch(error => {
            console.log('>>>> ERROR - getContractRecords');
            console.log(error);
        });
    }

    @api loadingData(contractNumber, contractService){
        this.loadData = false;
        this.meterReadingError = false;
        this.meterReadingErrorMessage = '';
        console.log('>>> contractService -> ' + contractService);
        console.log('>>> contractNumber -> ' + contractNumber);
        this.contractNumber = contractNumber;
        this.contractService = contractService;
        this.configurationData();
    }

    //@wire(getMeterReadingRecords, {contractCode : '$contractNumber', modality: '$modality'})
    //wiredRecords({ error, data }) {
    //    if(data) {
    //        if(data.success){
    //            var obj = JSON.parse(data.data);
    //            this.meterReadingData = obj.data;
    //            console.log(JSON.stringify(this.meterReadingData));
    //            this.detailTableHeader = 'Letture contratto > ' + this.contractNumber;
    //            this.loadData = true;
    //        } else {
    //            this.meterReadingError = true;
    //            this.meterReadingErrorMessage = data.message;
    //        }
    //        this.dataLoaded();
    //    } else if(error) {
    //        console.log('>>>> ERROR > getMeterReadingRecords');
    //        this.meterReadingError = true;
    //        this.meterReadingErrorMessage = 'ERROR';
    //    }
    //}

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

    handleRowSelection = event => {
        let selectRow = event.detail.selectedRows[0];
        console.log('NonStandAlone -> ' +this.nonStandAlone);
        console.log('Select Row -> ' + JSON.stringify(selectRow));
        if(this.nonStandAlone){
            console.log('InsideNonStandAloneEvent');
            console.log('ChildEvent -> ' + selectRow);
            console.log('SettoreMerceologico >>> ' + selectRow.settoreMerceologico);
            if(selectRow.settoreMerceologico === 'Energia Elettrica')
            {
                selectRow = this.meterReadingData.filter(element => element.dataLetturaPianificata === selectRow.dataLetturaPianificata);
                console.log('3 FASCE LETTURA >>> ' + JSON.stringify(selectRow))
            }
            this.dispatchEvent(new CustomEvent('rowselection',{detail: selectRow}));
        }
        return;
    }

    changeModality(event){
        this.showChooseType = true;
    }

    closeModalHandler(event){
        this.showChooseType = false;
    }

    setNewChoise(event){
        this.showChooseType = false;
        this.modality = event.detail.stmtName;
        console.log('>>> modality -> ' + this.modality);
        this.loadData = false;
        this.detailBackendCall();
    }

}