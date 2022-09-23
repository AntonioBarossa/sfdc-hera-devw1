import {api} from 'lwc';
import HdtRecordEditFormFlow from 'c/hdtRecordEditFormFlow';

export default class HdtRecordEditFormFlowAdvanced extends HdtRecordEditFormFlow {

    @api processType="Rifiuti Hergo";
    @api recordId;
    @api saveButton;
    @api objectName;
    @api labelSaveButton;
    @api previousButton;
    @api labelPreviousButton;
    @api cancelButton;
    @api draftButton;
    @api labelDraftButton;
    @api density;
    @api recordType;
    @api saveInDraft;
    @api cancelCase;
    @api nextStep;
    @api showReadOnly;
    @api labelInputSection;
    @api labelReadOnlySection;
    @api variantSaveButton;
    @api outputId;
    @api accountss;

    virtualOnChange(event){
        
    }
}