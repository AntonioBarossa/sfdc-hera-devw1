import { LightningElement } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

//Apex Methods
import getCSVBody from '@salesforce/apex/HDT_LC_MassiveLoader.getCSVBody';
import initialize from '@salesforce/apex/HDT_LC_MassiveLoader.initialize';
import checkCSV from '@salesforce/apex/HDT_LC_MassiveLoader.checkCSV';
import createMassiveLoaderRequest from '@salesforce/apex/HDT_LC_MassiveLoader.createMassiveLoaderRequest';
import updateMassiveLoaderRequest from '@salesforce/apex/HDT_LC_MassiveLoader.updateMassiveLoaderRequest';

//Custom Labels
import massiveLoader from '@salesforce/label/c.MassiveLoader';
import massiveLoaderDesiredAction from '@salesforce/label/c.MassiveLoaderDesiredAction';
import massiveLoaderImportSuccess from '@salesforce/label/c.MassiveLoaderImportSuccess';
import success from '@salesforce/label/c.Success';
import error from '@salesforce/label/c.Error';
import massiveLoaderRequestType from '@salesforce/label/c.MassiveLoaderRequestType';
import massiveLoaderImportProcesses from '@salesforce/label/c.MassiveLoaderImportProcesses';
import massiveLoaderExportTemplate from '@salesforce/label/c.MassiveLoaderExportTemplate';
import massiveLoaderPicklistPlaceholder from '@salesforce/label/c.MassiveLoaderPicklistPlaceholder';
import massiveLoaderFileDownload from '@salesforce/label/c.MassiveLoaderFileDownload';
import massiveLoaderFileUpload from '@salesforce/label/c.MassiveLoaderFileUpload';
import massiveLoaderReset from '@salesforce/label/c.MassiveLoaderReset';
import massiveLoaderCompleteImport from '@salesforce/label/c.MassiveLoaderCompleteImport';
import massiveLoaderGoToRecord from '@salesforce/label/c.MassiveLoaderGoToRecord';
import massiveLoaderFileCheckError from '@salesforce/label/c.MassiveLoaderFileCheckError';


export default class HdtMassiveLoader extends LightningElement {

    labels = {
        massiveLoaderImportSuccess: massiveLoaderImportSuccess,
        success: success,
        error: error,
        massiveLoaderRequestType: massiveLoaderRequestType,
        massiveLoaderImportProcesses: massiveLoaderImportProcesses,
        massiveLoaderExportTemplate: massiveLoaderExportTemplate,
        massiveLoader: massiveLoader,
        massiveLoaderDesiredAction: massiveLoaderDesiredAction,
        massiveLoaderPicklistPlaceholder: massiveLoaderPicklistPlaceholder,
        massiveLoaderFileDownload: massiveLoaderFileDownload,
        massiveLoaderFileUpload: massiveLoaderFileUpload,
        massiveLoaderReset: massiveLoaderReset,
        massiveLoaderCompleteImport: massiveLoaderCompleteImport,
        massiveLoaderGoToRecord: massiveLoaderGoToRecord,
        massiveLoaderFileCheckError: massiveLoaderFileCheckError,
    };
    
    processTypeOptions;

    //Export
    exportTypeValue;
    exportCSV;
    downloadDisabled;
    exportFileName;

    //Import
    importTypeValue;
    fileUploadDisabled;
    importDisabled;
    massiveLoaderRecordId;
    fileName;
    contentVersionId;

    navigateDisabled;

    get importFileFormat() {
        return ['.csv'];
    }

    connectedCallback() {

        this.exportTypeValue = null;
        this.exportCSV = null;
        this.downloadDisabled = true;
        this.exportFileName = null;

        this.importTypeValue = null;
        this.fileUploadDisabled = true;
        this.importDisabled = true;
        this.massiveLoaderRecordId = null;
        this.fileName = null;
        this.contentVersionId = null;

        this.navigateDisabled = true;

        initialize()
        .then(result => {

            if (result.error == false) {

                this.processTypeOptions = result.processesPicklist;
                // console.log(JSON.stringify(result.processesPicklist));
                
            } else {

                console.log('hdtMassiveLoader.initialize - Error: ' + result.errorMessage);
                console.log('hdtMassiveLoader.initialize - ErrorStackTrace: ' + result.errorStackTraceString);

                this.handleToastEvent('Error!', result.errorMessage, 'error', null);

            }
        })
        .catch(error => {

            console.log('hdtMassiveLoader.initialize - Error: ', error);

        })

    }


    handleTypeChangeExport(event) {

        this.exportTypeValue = event.target.value;
        this.exportFileName = event.target.options.find(opt => opt.value === this.exportTypeValue).label + '.csv';


        getCSVBody({
            selectedProcessName: this.exportTypeValue
        })
        .then(result => {

            if (result.error == false) {

                this.exportCSV = result.urlCSVResource;
                this.downloadDisabled = false;

            } else {

                console.log('hdtMassiveLoader.getCSVBody - Error: ' + result.errorMessage);
                console.log('hdtMassiveLoader.getCSVBody - ErrorStackTrace: ' + result.errorStackTraceString);

                this.handleToastEvent(error + '!', result.errorMessage, 'error', null);

            }
        })
        .catch(error => {

            console.log('hdtMassiveLoader.getCSVBody - Error: ', error);

        })

    }

    handleTypeChangeImport(event) {

        this.importTypeValue = event.target.value;

        if (this.massiveLoaderRecordId == null) {

            createMassiveLoaderRequest({
                selectedProcessName: this.importTypeValue
            })
            .then(result => {
    
                if (result.error == false) {
    
                    this.massiveLoaderRecordId = result.massiveLoaderRequestId;
                    this.fileUploadDisabled = false;
    
                } else {
    
                    console.log('hdtMassiveLoader.createMassiveLoaderRequest - Error: ' + result.errorMessage);
                    console.log('hdtMassiveLoader.createMassiveLoaderRequest - ErrorStackTrace: ' + result.errorStackTraceString);

                    this.handleToastEvent(error + '!', result.errorMessage, 'error', null);

                }
            })
            .catch(error => {
    
                console.log('hdtMassiveLoader.createMassiveLoaderRequest - Error: ', error);
    
            })

        } else {

            updateMassiveLoaderRequest({
                massiveLoaderRequestId: this.massiveLoaderRequestId,
                selectedProcessName: this.importTypeValue
            })
            .then(result => {
    
                if (result.error == true) {
    
                    console.log('hdtMassiveLoader.createMassiveLoaderRequest - Error: ' + result.errorMessage);
                    console.log('hdtMassiveLoader.createMassiveLoaderRequest - ErrorStackTrace: ' + result.errorStackTraceString);

                    this.handleToastEvent(error + '!', result.errorMessage, 'error', null);

                }
            })
            .catch(error => {
    
                console.log('hdtMassiveLoader.createMassiveLoaderRequest - Error: ', error);
    
            })

        }

    }

    handleCSVDownload(event) {
                
        let target = this.template.querySelector(`[data-id="downloadCSV"]`);
        target.click();

    }

    handleUploadFinished(event) {

        this.importDisabled = false;
        this.fileUploadDisabled = true;
        this.fileName = event.detail.files[0].name;
        this.contentVersionId = event.detail.files[0].contentVersionId;

    }

    handleReset(event) {

        this.connectedCallback();

    }

    handleCSVConfirm(event) {

        checkCSV({
            fileName: this.fileName,
            contentVersionId: this.contentVersionId,
            selectedProcessName: this.importTypeValue,
            massiveLoaderRequestId: this.massiveLoaderRecordId
        })
        .then(result => {

            if (result.error == false) {

                var message = massiveLoaderImportSuccess + this.massiveLoaderRecordId;
                console.log(message);

                this.handleToastEvent(success + '!', message, 'success', 'sticky');

                this.importDisabled = true;
                
                this.navigateDisabled = false;

            } else {

                this.fileUploadDisabled = false;
                this.importDisabled = true;

                console.log('hdtMassiveLoader.checkCSV - Error: ' + result.errorMessage);
                console.log('hdtMassiveLoader.checkCSV - ErrorStackTrace: ' + result.errorStackTraceString);

                // this.handleToastEvent(error + '!', result.errorMessage, 'error');
                this.handleToastEvent(error + '!', this.labels.massiveLoaderFileCheckError, 'error', null);

            }
        })
        .catch(error => {

            console.log('hdtMassiveLoader.checkCSV - Error: ', error);

        })

    }

    handleChangeTab(event) {

        let selectedTab = event.target.id;
        console.log(selectedTab);

        if(selectedTab.includes('importTab')) {

            this.template.querySelector('[data-id="importTab"]').className = 'slds-tabs_default__item slds-is-active';
            this.template.querySelector('[data-id="exportTab"]').className = 'slds-tabs_default__item';
            
            this.template.querySelector('[data-id="importTab-content"]').className = 'slds-tabs_default__content slds-show';
            this.template.querySelector('[data-id="exportTab-content"]').className = 'slds-tabs_default__content slds-hide';

        } else {

            this.template.querySelector('[data-id="importTab"]').className = 'slds-tabs_default__item';
            this.template.querySelector('[data-id="exportTab"]').className = 'slds-tabs_default__item slds-is-active';
            
            this.template.querySelector('[data-id="importTab-content"]').className = 'slds-tabs_default__content slds-hide';
            this.template.querySelector('[data-id="exportTab-content"]').className = 'slds-tabs_default__content slds-show';

        }
    }

    handleGoToRecord(event) {

        const recordId = this.massiveLoaderRecordId;

        const gotorecordEvent = new CustomEvent('gotorecord', { detail: {recordId} });

        this.handleReset(event);

        this.dispatchEvent(gotorecordEvent);
    }

    handleToastEvent(title, message, variant, mode) {

        const toastEvent = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
            mode: mode
        });

        this.dispatchEvent(toastEvent);

    }

}