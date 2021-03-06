/**********************************************************************
 * Copyright (C) 2006-2016 by Consultingwerk Ltd. ("CW") -            *
 * www.consultingwerk.de and other contributors as listed             *
 * below.  All Rights Reserved.                                       *
 *                                                                    *
 *  Software is distributed on an "AS IS", WITHOUT WARRANTY OF ANY    *
 *   KIND, either express or implied.                                 *
 *                                                                    *
 *  Contributors:                                                     *
 *                                                                    *
 **********************************************************************/
/*------------------------------------------------------------------------
    File        : CustomerBusinessEntity
    Purpose     : Sample for a Business Entity using an XML file as it's
                  data source
    Syntax      :
    Description :
    Author(s)   : Mike Fechner / Consultingwerk Ltd.
    Created     : Tue Jun 21 21:19:43 CEST 2016
    Notes       :
  ----------------------------------------------------------------------*/

BLOCK-LEVEL ON ERROR UNDO, THROW.

USING Consultingwerk.Util.* FROM PROPATH.
USING Consultingwerk.*                                    FROM PROPATH.
USING Consultingwerk.CcsSamples.BusinessEntity.*          FROM PROPATH.
USING Consultingwerk.CcsSamples.BusinessEntity.Customer.* FROM PROPATH .
USING Consultingwerk.CcsSamples.Framework.BusinessLogic.* FROM PROPATH .
USING Ccs.BusinessLogic.*                                 FROM PROPATH  .
USING Progress.Lang.*                                     FROM PROPATH .

CLASS Consultingwerk.CcsSamples.BusinessEntity.Customer.CustomerBusinessEntity
    IMPLEMENTS IUpdatableBusinessEntity:

    {Consultingwerk/CcsSamples/BusinessEntity/Customer/dsCustomer.i}

    DEFINE QUERY qCustomer FOR Customer .

    DEFINE DATA-SOURCE srcCustomer FOR QUERY qCustomer .

    /**
     * Purpose: Default constructor for the CustomerBusinessEntity class
     * Notes:
     */
    CONSTRUCTOR PUBLIC CustomerBusinessEntity ():
        SUPER ().

        /* noop */

    END CONSTRUCTOR.

    /**
     * Purpose: Disposes the object instance
     * Notes:
     */
    METHOD PUBLIC VOID dispose ():

        /* noop */

    END METHOD.

    /**
     * Purpose: Opens the Data Source query
     * Notes:
     * @param poRequest The IGetDataRequest instance with the getData request parameters
     */
    METHOD PROTECTED VOID OpenQuery (poRequest AS Ccs.BusinessLogic.IGetDataRequest):

        DEFINE VARIABLE oGetDataTableRequest AS IGetDataTableRequest NO-UNDO .
        DEFINE VARIABLE oQueryBuilder        AS QueryBuilder         NO-UNDO .

        IF NOT VALID-OBJECT (poRequest) THEN DO:
            QUERY qCustomer:QUERY-PREPARE ("FOR EACH Customer") .
            RETURN.
        END.

        IF VALID-OBJECT (poRequest:NamedQuery) THEN DO:
            THIS-OBJECT:OpenNamedQuery (poRequest:NamedQuery) .
        END.
        ELSE DO:

            oGetDataTableRequest = GetDataRequest:GetDataTableRequestByName(poRequest, "eCustomer") .

            IF VALID-OBJECT (oGetDataTableRequest) THEN DO:

                IF oGetDataTableRequest:QueryString > "" THEN DO:
                    QUERY qCustomer:QUERY-PREPARE("for each Customer where " + oGetDataTableRequest:QueryString) .

                    RETURN .
                END.

                IF VALID-OBJECT (oGetDataTableRequest:QueryDefinition) THEN DO:

                    oQueryBuilder = NEW QueryBuilder () .

                    QUERY qCustomer:QUERY-PREPARE (oQueryBuilder:BuildQueryString ("Customer",
                                                                                   oGetDataTableRequest:QueryDefinition)) .

                    RETURN .
                END.
            END.
        END.

        QUERY qCustomer:QUERY-PREPARE ("FOR EACH Customer") .

    END METHOD.

    /**
     * Purpose: Opens a named query
     * Notes:
     * @param poNamedQuery The named query parameter
     */
    METHOD PROTECTED VOID OpenNamedQuery (poNamedQuery AS INamedQuery):

        // DEFINE VARIABLE oDateHolder      AS DateHolder      NO-UNDO .
        // DEFINE VARIABLE oCharacterHolder AS CharacterHolder NO-UNDO .

        CASE poNamedQuery:Name:

            OTHERWISE
                UNDO, THROW NEW AppError (SUBSTITUTE ("Invalid named query: &1", poNamedQuery:Name), 0) .
        END.

    END METHOD.

    /**
     * Purpose: Performs a read request
     * Notes:
     * @param poRequest The IGetDataRequest instance with the getData request parameters
     * @param phDataset OUTPUT Dataset
     * @return The IGetDataResponse instance
     */
    METHOD PUBLIC Ccs.BusinessLogic.IGetDataResponse getData (poRequest AS Ccs.BusinessLogic.IGetDataRequest,
                                                              OUTPUT DATASET-HANDLE phDataset):

        IF NOT VALID-HANDLE (phDataset) THEN
            ASSIGN phDataset = DATASET dsCustomer:HANDLE .

        RETURN THIS-OBJECT:getData (poRequest, OUTPUT DATASET-HANDLE phDataset BY-REFERENCE) .

    END METHOD.

    /**
     * Purpose: Performs a read request
     * Notes:
     * @param poRequest The IGetDataRequest instance with the getData request parameters
     * @param dsMatches OUTPUT Dataset
     * @return The IGetDataResponse instance
     */
    METHOD PUBLIC Ccs.BusinessLogic.IGetDataResponse getData (poRequest AS Ccs.BusinessLogic.IGetDataRequest,
                                                              OUTPUT DATASET dsCustomer):

        DATASET dsCustomer:EMPTY-DATASET () .

        BUFFER eCustomer:ATTACH-DATA-SOURCE (DATA-SOURCE srcCustomer:HANDLE) .

        THIS-OBJECT:OpenQuery (poRequest) .

        DATASET dsCustomer:FILL .

        FINALLY:
            IF VALID-HANDLE (BUFFER eCustomer:DATA-SOURCE) THEN
                BUFFER eCustomer:DETACH-DATA-SOURCE () .
        END FINALLY.

    END METHOD .

    /**
     *  Purpose: Returns an empty instance of the primary ProDataset to the caller
     *  Notes:   Used for catalog generation or initialization of dynamic user
     *           interfaces etc.
     *  @param phDataset OUTPUT Dataset (not intended to be called BY-REFERENCE)
     */
    METHOD PUBLIC VOID getDataset (OUTPUT DATASET-HANDLE phDataset):

        DATASET dsCustomer:EMPTY-DATASET () .

        phDataset = DATASET dsCustomer:HANDLE .

    END METHOD.

    /**
     * Purpose: Returns the count of the total number of result records or a guess
     *          of the result count to the caller
     * Notes:
     * @param poRequest The IGetDataRequest instance with the getResultCount request parameters
     * @return The IGetResultCountResponse instance
     */
    METHOD PUBLIC Ccs.BusinessLogic.IGetResultCountResponse getResultCount (poRequest AS Ccs.BusinessLogic.IGetDataRequest):


        THIS-OBJECT:OpenQuery (poRequest) .
/*
        RETURN NEW GetResultCountResponse ("eCustomer",
                                           QUERY qMatches:NUM-RESULTS,
                                           TRUE) .
*/
    END METHOD.

    /**
     * Purpose: Initializes the Service
     * Notes:   Imports ttMatches.xml
     *
     */
    METHOD PUBLIC VOID initialize ():

        /* noop */

    END METHOD.

    /**
     * Purpose: Stores data modifications in the persistent storage (typically a
     *          database)
     * Notes:   The output dataset will contain validation error messages in the
     *          ERROR-STRING attributes of the record buffers. Records with Errors
     *          will also have the ERROR attribute set to TRUE. When at least a single
     *          record has a validation error, the ERROR attribute of the ProDataset
     *          is assigned to TRUE as well
     * @param phDataset INPUT-OUTPUT Dataset containing modified records to be processed (should be passed BY-REFERENCE)
     * @param poUpdateDataRequest The optional request object that allows to provide custom instructions to the method
     * @return An optional response object returned by the method
     */
    METHOD PUBLIC Progress.Lang.Object updateData (INPUT-OUTPUT DATASET-HANDLE phDataset,
                                                   poUpdateDataRequest AS IUpdateDataRequest):

        IF NOT VALID-HANDLE (phDataset) THEN
            ASSIGN phDataset = DATASET dsCustomer:HANDLE .

        RETURN THIS-OBJECT:updateData (INPUT-OUTPUT DATASET-HANDLE phDataset BY-REFERENCE, poUpdateDataRequest) .

    END METHOD.

    /**
     * Purpose: Stores data modifications in the persistent storage (typically a
     *          database)
     * Notes:   The output dataset will contain validation error messages in the
     *          ERROR-STRING attributes of the record buffers. Records with Errors
     *          will also have the ERROR attribute set to TRUE. When at least a single
     *          record has a validation error, the ERROR attribute of the ProDataset
     *          is assigned to TRUE as well
     * @param phDataset INPUT-OUTPUT Dataset containing modified records to be processed (should be passed BY-REFERENCE)
     * @param poUpdateDataRequest The optional request object that allows to provide custom instructions to the method
     * @return An optional response object returned by the method
     */
    METHOD PUBLIC Progress.Lang.Object updateData (INPUT-OUTPUT DATASET dsCustomer,
                                                   poUpdateDataRequest AS IUpdateDataRequest):

        THIS-OBJECT:ValidateData () .

        IF DATASET dsCustomer:ERROR = TRUE THEN
            RETURN ? .

        BUFFER eCustomer:ATTACH-DATA-SOURCE (DATA-SOURCE srcCustomer:HANDLE) .

        FOR EACH eCustomerBefore:
            BUFFER eCustomerBefore:SAVE-ROW-CHANGES (1, "CustNum") .
        END.

        FINALLY:
            IF VALID-HANDLE (BUFFER eCustomer:DATA-SOURCE) THEN
                BUFFER eCustomer:DETACH-DATA-SOURCE () .
        END FINALLY.

    END METHOD .

    /**
     * Purpose:
     * Notes:
     *
     */
    METHOD PROTECTED VOID ValidateData ():

        FOR EACH eCustomerBefore WHERE ROW-STATE (eCustomerBefore) = ROW-DELETED:

            DatasetHelper:AddErrorString(BUFFER eCustomerBefore:HANDLE, "You can't delete customers.").

        END .

        FOR EACH eCustomer WHERE ROW-STATE (eCustomer) = ROW-CREATED OR ROW-STATE (eCustomer) = ROW-MODIFIED:

            FIND eCustomerBefore WHERE ROWID (eCustomerBefore) = BUFFER eCustomer:BEFORE-ROWID .

            IF ROW-STATE (eCustomer) = ROW-MODIFIED THEN DO:

                IF eCustomer.CustNum <> eCustomerBefore.CustNum THEN
                    DatasetHelper:AddErrorString(BUFFER eCustomer:HANDLE, "You cannot modify cust num.", "CustNum") .
            END.

            IF eCustomer.Name = ? OR eCustomer.Name = "" THEN
                DatasetHelper:AddErrorString(BUFFER eCustomer:HANDLE, "Name may not be empty.", "Name") .

        END.

    END METHOD.

END CLASS.
