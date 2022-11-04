trigger HDT_ContentDocumentLink on ContentDocumentLink (before insert, after insert) {
    new HDT_TRH_ContentDocumentLink().run();
}