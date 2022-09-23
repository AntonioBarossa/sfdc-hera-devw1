import {api} from 'lwc';
import HdtRecordEditFormFlow from 'c/hdtRecordEditFormFlow';

export default class HdtRecordEditFormFlowAdvanced extends HdtRecordEditFormFlow {

    @api processType;
    @api objectName;
    @api recordId;
    @api saveButton;
    @api cancelButton;
    @api previousButton;
    @api draftButton;
    @api density;
    @api recordType;
    @api saveInDraft;
    @api cancelCase;
    @api addContentDocument;
    @api contentDocumentLabel;
    @api acceptedFormats;
    @api nextStep;
    @api showReadOnly;
    @api labelSaveButton;
    @api labelDraftButton;
    @api labelPreviousButton;
    @api labelInputSection;
    @api labelReadOnlySection;
    @api availableActions = [];
    @api variantSaveButton;
    @api outputId;
    @api documentRecordId;

    virtualOnChange(event){
        
    }
}