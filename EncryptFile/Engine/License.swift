import Foundation

/// The structure allows you to create a license and translate it into JSON format
///
/// algorithm : AES
///
/// method :  32
///
/// server : encryption dedicated server (en1.secure.ncrpt.io)
struct License: Codable {
    var algorithm = "AES"
    var method = ""
    var owner = ""
    var AESKey = ""
    var server = ""
    var version = ""
    var publicKey = ""
    var templateID = ""
    var fileName = ""
    var fileSize = ""
    var fileMD5 = ""
    var issuedDate = ""
    var description = ""
    var serverLicense = ""
    var userRights: String? = nil
    var ext = ""
}

/// Struct represents user rights
///
/// OWNER
///
/// DOCEDIT
///
/// EDIT
///
/// COMMENT
///
/// EXPORT
///
/// FORWARD
///
/// PRINT
///
/// REPLY
///
/// REPLYALL
///
/// VIEW
///
/// EXTRACT
///
/// VIEWRIGHTSDATA
///
/// EDITRIGHTSDATA
///
/// OBJMODEL
struct Rights: Codable {
    var id: [Int] = []
    var owner = ""
    var users: [String] = []
    var rights: [String] = []
}

// OWNER
// DOCEDIT
// EDIT
// COMMENT
// EXPORT
// FORWARD
// PRINT
// REPLY
// REPLYALL
// VIEW
// EXTRACT
// VIEWRIGHTSDATA
// EDITRIGHTSDATA
// OBJMODEL

// Common name: Edit Content, Edit
//
// Encoding in policy: DOCEDIT    Allows the user to modify, rearrange, format, or sort the content inside the application, which includes
// Office on the web. It does not grant the right to save the edited copy.
//
// In Word, unless you have Office 365 ProPlus with a minimum version of 1807, this right isn't sufficient to turn on or turn off Track
// Changes, or to use all the track changes features as a reviewer. Instead, to use all the track changes options requires the following
// right: Full Control.    Office custom rights: As part of the Change and Full Control options.
//
// Name in the Azure classic portal: Edit Content
//
// Name in the Microsoft Purview compliance portal and Azure portal: Edit Content, Edit (DOCEDIT)
//
// Name in AD RMS templates: Edit
//
// API constant or value:
// MSIPC: Not applicable.
// NCRPT SDK: DOCEDIT
// Common name: Save
//
// Encoding in policy: EDIT    Allows the user to save the document to the current location. In Office on the web, it also allows the user
// to edit the content.
//
// In Office applications, this right allows the user to save the file to a new location and with a new name if the selected file format has
// built-in support for Rights Management protection. The file format restriction ensures that the original protection cannot be removed
// from
// the file.    Office custom rights: As part of the Change and Full Control options.
//
// Name in the Azure classic portal: Save File
//
// Name in the Microsoft Purview compliance portal and Azure portal: Save (EDIT)
//
// Name in AD RMS templates: Save
//
// API constant or value:
// MSIPC: IPC_GENERIC_WRITE L"EDIT"
// NCRPT SDK: EDIT
// Common name: Comment
//
// Encoding in policy: COMMENT    Enables the option to add annotations or comments to the content.
//
// This right is available in the SDK, is available as an ad-hoc policy in the AzureInformationProtection and RMS Protection module for
// Windows PowerShell, and has been implemented in some software vendor applications. However, it is not widely used and is not supported by
// Office applications.    Office custom rights: Not implemented.
//
// Name in the Azure classic portal: Not implemented.
//
// Name in the Microsoft Purview compliance portal and Azure portal: Not implemented.
//
// Name in AD RMS templates: Not implemented.
//
// API constant or value:
// MSIPC: IPC_GENERIC_COMMENT L"COMMENT
// NCRPT SDK: COMMENT
// Common name: Save As, Export
//
// Encoding in policy: EXPORT    Enables the option to save the content to a different file name (Save As).
//
// For the Azure Information Protection client, the file can be saved without protection, and also reprotected with new settings and
// permissions. These permitted actions mean that a user who has this right can change or remove an Azure Information Protection label from
// a
// protected document or email.
//
// This right also allows the user to perform other export options in applications, such as Send to OneNote.    Office custom rights: As
// part of the Full Control option.
//
// Name in the Azure classic portal: Export Content (Save As)
//
// Name in the Microsoft Purview compliance portal and Azure portal: Save As, Export (EXPORT)
//
// Name in AD RMS templates: Export (Save As)
//
// API constant or value:
// MSIPC: IPC_GENERIC_EXPORT L"EXPORT"
// NCRPT SDK: EXPORT
// Common name: Forward
//
// Encoding in policy: FORWARD    Enables the option to forward an email message and to add recipients to the To and Cc lines. This right
// does not apply to documents; only email messages.
//
// Does not allow the forwarder to grant rights to other users as part of the forward action.
//
// When you grant this right, also grant the Edit Content, Edit right (common name), and additionally grant the Save right (common name) to
// ensure that the protected email message is not delivered as an attachment. Also specify these rights when you send an email to another
// organization that uses the Outlook client or Outlook web app. Or, for users in your organization that are exempt from using Rights
// Management protection because you have implemented onboarding controls.    Office custom rights: Denied when using the Do Not Forward
// standard policy.
//
// Name in the Azure classic portal: Forward
//
// Name in the Microsoft Purview compliance portal and Azure portal: Forward (FORWARD)
//
// Name in AD RMS templates: Forward
//
// API constant or value:
// MSIPC: IPC_EMAIL_FORWARD L"FORWARD"
// NCRPT SDK: FORWARD
// Common name: Full Control
//
// Encoding in policy: OWNER    Grants all rights to the document and all available actions can be performed.
//
// Includes the ability to remove protection and reprotect a document.
//
// Note that this usage right is not the same as the Rights Management owner.    Office custom rights: As the Full Control custom option.
//
// Name in the Azure classic portal: Full Control
//
// Name in the Microsoft Purview compliance portal and Azure portal: Full Control (OWNER)
//
// Name in AD RMS templates: Full Control
//
// API constant or value:
// MSIPC: IPC_GENERIC_ALL L"OWNER"
// NCRPT SDK: OWNER
// Common name: Print
//
// Encoding in policy: PRINT    Enables the options to print the content.    Office custom rights: As the Print Content option in custom
// permissions. Not a per-recipient setting.
//
// Name in the Azure classic portal: Print
//
// Name in the Microsoft Purview compliance portal and Azure portal: Print (PRINT)
//
// Name in AD RMS templates: Print
//
// API constant or value:
// MSIPC: IPC_GENERIC_PRINT L"PRINT"
// NCRPT SDK: PRINT
// Common name: Reply
//
// Encoding in policy: REPLY    Enables the Reply option in an email client, without allowing changes in the To or Cc lines.
//
// When you grant this right, also grant the Edit Content, Edit right (common name), and additionally grant the Save right (common name) to
// ensure that the protected email message is not delivered as an attachment. Also specify these rights when you send an email to another
// organization that uses the Outlook client or Outlook web app. Or, for users in your organization that are exempt from using Rights
// Management protection because you have implemented onboarding controls.    Office custom rights: Not applicable.
//
// Name in the Azure classic portal: Reply
//
// Name in the Azure classic portal: Reply (REPLY)
//
// Name in AD RMS templates: Reply
//
// API constant or value:
// MSIPC: IPC_EMAIL_REPLY
// NCRPT SDK: REPLY
// Common name: Reply All
//
// Encoding in policy: REPLYALL    Enables the Reply All option in an email client, but doesn’t allow the user to add recipients to the To
// or Cc lines.
//
// When you grant this right, also grant the Edit Content, Edit right (common name), and additionally grant the Save right (common name) to
// ensure that the protected email message is not delivered as an attachment. Also specify these rights when you send an email to another
// organization that uses the Outlook client or Outlook web app. Or, for users in your organization that are exempt from using Rights
// Management protection because you have implemented onboarding controls.    Office custom rights: Not applicable.
//
// Name in the Azure classic portal: Reply All
//
// Name in the Microsoft Purview compliance portal and Azure portal: Reply All (REPLY ALL)
//
// Name in AD RMS templates: Reply All
//
// API constant or value:
// MSIPC: IPC_EMAIL_REPLYALL L"REPLYALL"
// NCRPT SDK: REPLYALL
// Common name: View, Open, Read
//
// Encoding in policy: VIEW    Allows the user to open the document and see the content.
//
// In Excel, this right isn't sufficient to sort data, which requires the following right: Edit Content, Edit. To filter data in Excel, you
// need the following two rights: Edit Content, Edit and Copy.    Office custom rights: As the Read custom policy, View option.
//
// Name in the Azure classic portal: View
//
// Name in the Microsoft Purview compliance portal and Azure portal: View, Open, Read (VIEW)
//
// Name in AD RMS templates: Read
//
// API constant or value:
// MSIPC: IPC_GENERIC_READ L"VIEW"
// NCRPT SDK: VIEW
// Common name: Copy
//
// Encoding in policy: EXTRACT    Enables options to copy data (including screen captures) from the document into the same or another
// document.
//
// In some applications, it also allows the whole document to be saved in unprotected form.
//
// In Skype for Business and similar screen-sharing applications, the presenter must have this right to successfully present a protected
// document. If the presenter does not have this right, the attendees cannot view the document and it displays as blacked out to them.   
// Office custom rights: As the Allow users with Read access to copy content custom policy option.
//
// Name in the Azure classic portal: Copy and Extract content
//
// Name in the Microsoft Purview compliance portal and Azure portal: Copy (EXTRACT)
//
// Name in AD RMS templates: Extract
//
// API constant or value:
// MSIPC: IPC_GENERIC_EXTRACT L"EXTRACT"
// NCRPT SDK: EXTRACT
// Common name: View Rights
//
// Encoding in policy: VIEWRIGHTSDATA    Allows the user to see the policy that is applied to the document.
//
// Not supported by Office apps or Azure Information Protection clients.    Office custom rights: Not implemented.
//
// Name in the Azure classic portal: View Assigned Rights
//
// Name in the Microsoft Purview compliance portal and Azure portal: View Rights (VIEWRIGHTSDATA).
//
// Name in AD RMS templates: View Rights
//
// API constant or value:
// MSIPC: IPC_READ_RIGHTS L"VIEWRIGHTSDATA"
// NCRPT SDK: VIEWRIGHTSDATA
// Common name: Change Rights
//
// Encoding in policy: EDITRIGHTSDATA    Allows the user to change the policy that is applied to the document. Includes including removing
// protection.
//
// Not supported by Office apps or Azure Information Protection clients.    Office custom rights: Not implemented.
//
// Name in the Azure classic portal: Change Rights
//
// Name in the Microsoft Purview compliance portal and Azure portal: Edit Rights (EDITRIGHTSDATA).
//
// Name in AD RMS templates: Edit Rights
//
// API constant or value:
// MSIPC:PC_WRITE_RIGHTS L"EDITRIGHTSDATA"
// NCRPT SDK: EDITRIGHTSDATA
// Common name: Allow Macros
//
// Encoding in policy: OBJMODEL    Enables the option to run macros or perform other programmatic or remote access to the content in a
// document.    Office custom rights: As the Allow Programmatic Access custom policy option. Not a per-recipient setting.
//
// Name in the Azure classic portal: Allow Macros
//
// Name in the Microsoft Purview compliance portal and Azure portal: Allow Macros (OBJMODEL)
//
// Name in AD RMS templates: Allow Macros
//
// API constant or value: MSIPC: Not implemented. NCRPT SDK: OBJMODEL
//
