--
-- PostgreSQL database dump
--

-- Dumped from database version 16.10
-- Dumped by pg_dump version 17.5

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: DocumentStatus; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public."DocumentStatus" AS ENUM (
    'PENDING',
    'RECEIVED',
    'PROCESSED',
    'APPROVED',
    'REJECTED',
    'PROCESSING'
);


ALTER TYPE public."DocumentStatus" OWNER TO postgres;

--
-- Name: DocumentType; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public."DocumentType" AS ENUM (
    'REGULAR',
    'VENDOR_INVOICE',
    'TEST_CERTIFICATE',
    'COMPLIANCE_DOC'
);


ALTER TYPE public."DocumentType" OWNER TO postgres;

--
-- Name: InvoiceStatus; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public."InvoiceStatus" AS ENUM (
    'RECEIVED',
    'UNDER_REVIEW',
    'APPROVED',
    'REJECTED',
    'PAID',
    'DISPUTED',
    'CANCELLED'
);


ALTER TYPE public."InvoiceStatus" OWNER TO postgres;

--
-- Name: ItemStatus; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public."ItemStatus" AS ENUM (
    'NEVER_SENT',
    'PARTIALLY_SENT',
    'COMPLETELY_SENT'
);


ALTER TYPE public."ItemStatus" OWNER TO postgres;

--
-- Name: LotPriority; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public."LotPriority" AS ENUM (
    'LOW',
    'MEDIUM',
    'HIGH',
    'URGENT'
);


ALTER TYPE public."LotPriority" OWNER TO postgres;

--
-- Name: LotStatus; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public."LotStatus" AS ENUM (
    'CREATED',
    'DOCUMENTS_PENDING',
    'INSPECTION_READY',
    'INSPECTION_CALLED',
    'INSPECTION_COMPLETED',
    'APPROVED',
    'REJECTED',
    'COMPLETED'
);


ALTER TYPE public."LotStatus" OWNER TO postgres;

--
-- Name: NotificationType; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public."NotificationType" AS ENUM (
    'INFO',
    'WARNING',
    'ERROR',
    'SUCCESS',
    'DOCUMENT_RECEIVED',
    'LOT_CREATED',
    'INSPECTION_READY',
    'DEADLINE_APPROACHING',
    'VENDOR_INVOICE_UPLOADED',
    'REDACTION_REQUIRED',
    'REDACTION_COMPLETED'
);


ALTER TYPE public."NotificationType" OWNER TO postgres;

--
-- Name: ProjectStatus; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public."ProjectStatus" AS ENUM (
    'ACTIVE',
    'COMPLETED',
    'SUSPENDED',
    'CANCELLED'
);


ALTER TYPE public."ProjectStatus" OWNER TO postgres;

--
-- Name: RevisionStatus; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public."RevisionStatus" AS ENUM (
    'PENDING',
    'APPROVED',
    'REJECTED',
    'APPLIED'
);


ALTER TYPE public."RevisionStatus" OWNER TO postgres;

--
-- Name: UserRole; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public."UserRole" AS ENUM (
    'ADMIN',
    'PROJECT_MANAGER',
    'DEPARTMENT_HEAD',
    'INSPECTOR',
    'VIEWER'
);


ALTER TYPE public."UserRole" OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: audit_logs; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.audit_logs (
    id text NOT NULL,
    action text NOT NULL,
    entity text NOT NULL,
    "entityId" text NOT NULL,
    "oldValues" jsonb,
    "newValues" jsonb,
    "userId" text NOT NULL,
    "projectId" text,
    "lotId" text,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "invoiceId" text
);


ALTER TABLE public.audit_logs OWNER TO postgres;

--
-- Name: categories; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.categories (
    id text NOT NULL,
    name text NOT NULL,
    "isActive" boolean DEFAULT true NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE public.categories OWNER TO postgres;

--
-- Name: clients; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.clients (
    id text NOT NULL,
    name text NOT NULL,
    email text,
    "isActive" boolean DEFAULT true NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE public.clients OWNER TO postgres;

--
-- Name: departments; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.departments (
    id text NOT NULL,
    name text NOT NULL,
    code text NOT NULL,
    emails text[] DEFAULT ARRAY[]::text[],
    "contactPerson" text NOT NULL,
    "isActive" boolean DEFAULT true NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE public.departments OWNER TO postgres;

--
-- Name: document_alternatives; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.document_alternatives (
    id text NOT NULL,
    "projectId" text NOT NULL,
    "primaryDocumentRequirementId" text NOT NULL,
    "alternativeName" text NOT NULL,
    "matchPatterns" text[] DEFAULT ARRAY[]::text[],
    "isActive" boolean DEFAULT true NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE public.document_alternatives OWNER TO postgres;

--
-- Name: document_requirements; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.document_requirements (
    id text NOT NULL,
    "projectDepartmentId" text NOT NULL,
    name text NOT NULL,
    description text,
    "serialNumberRange" text,
    "isMandatory" boolean DEFAULT true NOT NULL,
    "isActive" boolean DEFAULT true NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE public.document_requirements OWNER TO postgres;

--
-- Name: documents; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.documents (
    id text NOT NULL,
    filename text NOT NULL,
    "originalName" text NOT NULL,
    "filePath" text NOT NULL,
    "fileSize" integer NOT NULL,
    "mimeType" text NOT NULL,
    status public."DocumentStatus" DEFAULT 'PENDING'::public."DocumentStatus" NOT NULL,
    "receivedAt" timestamp(3) without time zone,
    "processedAt" timestamp(3) without time zone,
    "extractedText" text,
    "aiAnalysis" text,
    "projectId" text NOT NULL,
    "lotId" text,
    "departmentId" text,
    "requirementId" text,
    "uploadedById" text NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL,
    "documentRequirementId" text,
    "documentType" public."DocumentType" DEFAULT 'REGULAR'::public."DocumentType" NOT NULL,
    "hasRedactedVersion" boolean DEFAULT false NOT NULL,
    "invoiceDate" timestamp(3) without time zone,
    "invoiceNumber" text,
    "isVendorInvoice" boolean DEFAULT false NOT NULL,
    "masterItemId" text,
    "originalDocumentId" text,
    "redactedDocumentId" text,
    "subItemIndex" integer,
    "subItemName" text,
    "vendorName" text
);


ALTER TABLE public.documents OWNER TO postgres;

--
-- Name: email_logs; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.email_logs (
    id text NOT NULL,
    "emailMessageId" text,
    "lotId" text,
    "projectId" text,
    "recipientEmail" text NOT NULL,
    "senderEmail" text,
    "emailType" text NOT NULL,
    status text NOT NULL,
    subject text,
    "sentAt" timestamp(3) without time zone,
    "processedAt" timestamp(3) without time zone,
    "userId" text NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "newValues" jsonb
);


ALTER TABLE public.email_logs OWNER TO postgres;

--
-- Name: extracted_document_requirements; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.extracted_document_requirements (
    id text NOT NULL,
    "projectId" text NOT NULL,
    name text NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE public.extracted_document_requirements OWNER TO postgres;

--
-- Name: inspection_agencies; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.inspection_agencies (
    id text NOT NULL,
    name text NOT NULL,
    email text,
    "isActive" boolean DEFAULT true NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE public.inspection_agencies OWNER TO postgres;

--
-- Name: invoice_items; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.invoice_items (
    id text NOT NULL,
    "invoiceId" text NOT NULL,
    "masterItemId" text,
    "lotItemId" text,
    description text NOT NULL,
    quantity integer NOT NULL,
    "unitPrice" double precision NOT NULL,
    "totalPrice" double precision NOT NULL,
    "taxRate" double precision DEFAULT 0 NOT NULL,
    "taxAmount" double precision DEFAULT 0 NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE public.invoice_items OWNER TO postgres;

--
-- Name: invoices; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.invoices (
    id text NOT NULL,
    "invoiceNumber" text NOT NULL,
    "projectId" text NOT NULL,
    "lotId" text,
    "supplierId" text,
    "totalAmount" double precision NOT NULL,
    "taxAmount" double precision DEFAULT 0 NOT NULL,
    "discountAmount" double precision DEFAULT 0 NOT NULL,
    "netAmount" double precision NOT NULL,
    currency text DEFAULT 'INR'::text NOT NULL,
    status public."InvoiceStatus" DEFAULT 'RECEIVED'::public."InvoiceStatus" NOT NULL,
    "invoiceDate" timestamp(3) without time zone NOT NULL,
    "dueDate" timestamp(3) without time zone,
    "paymentDate" timestamp(3) without time zone,
    "receivedDate" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "documentId" text,
    "approvedById" text,
    "approvedAt" timestamp(3) without time zone,
    "rejectionReason" text,
    description text,
    "vendorReference" text,
    "poReference" text,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL,
    "createdById" text NOT NULL
);


ALTER TABLE public.invoices OWNER TO postgres;

--
-- Name: item_suppliers; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.item_suppliers (
    id text NOT NULL,
    "masterItemId" text NOT NULL,
    "supplierId" text NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE public.item_suppliers OWNER TO postgres;

--
-- Name: lot_items; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.lot_items (
    id text NOT NULL,
    "lotId" text NOT NULL,
    "masterItemId" text NOT NULL,
    quantity integer NOT NULL,
    "internalDetails" text,
    "isRevisionItem" boolean DEFAULT false NOT NULL,
    "hasMixedQuantities" boolean DEFAULT false NOT NULL,
    "revisionQuantity" integer DEFAULT 0,
    "newQuantity" integer DEFAULT 0,
    "approvedQuantity" integer,
    "rejectedQuantity" integer,
    "rejectionReason" text,
    "selectedSupplierId" text,
    "useCustomPacking" boolean DEFAULT false NOT NULL,
    "customPackingDetails" jsonb,
    "packingNotes" text,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE public.lot_items OWNER TO postgres;

--
-- Name: lot_revisions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.lot_revisions (
    id text NOT NULL,
    "lotId" text NOT NULL,
    "originalLotId" text NOT NULL,
    "masterItemId" text,
    "itemDescription" text NOT NULL,
    "originalQuantity" integer NOT NULL,
    "revisedQuantity" integer NOT NULL,
    "quantityDiff" integer NOT NULL,
    reason text NOT NULL,
    status public."RevisionStatus" DEFAULT 'PENDING'::public."RevisionStatus" NOT NULL,
    "requestedById" text NOT NULL,
    "approvedById" text,
    "approvedAt" timestamp(3) without time zone,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE public.lot_revisions OWNER TO postgres;

--
-- Name: lots; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.lots (
    id text NOT NULL,
    "lotNumber" text NOT NULL,
    "projectId" text NOT NULL,
    priority public."LotPriority" DEFAULT 'MEDIUM'::public."LotPriority" NOT NULL,
    "inspectionDate" timestamp(3) without time zone,
    notes text,
    status public."LotStatus" DEFAULT 'CREATED'::public."LotStatus" NOT NULL,
    "hasRevisions" boolean DEFAULT false NOT NULL,
    "totalValue" double precision NOT NULL,
    progress double precision DEFAULT 0 NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL,
    "createdById" text NOT NULL,
    "stakeholderName" text
);


ALTER TABLE public.lots OWNER TO postgres;

--
-- Name: master_items; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.master_items (
    id text NOT NULL,
    "projectId" text NOT NULL,
    "serialNumber" integer NOT NULL,
    description text NOT NULL,
    unit text NOT NULL,
    "totalQuantity" integer NOT NULL,
    "remainingQuantity" integer NOT NULL,
    rate double precision NOT NULL,
    supplier text,
    status public."ItemStatus" DEFAULT 'NEVER_SENT'::public."ItemStatus" NOT NULL,
    "lastLotRevisedQty" integer DEFAULT 0 NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL,
    "discountAmount" double precision,
    "discountPercentage" double precision,
    percentage double precision,
    "qtyPerCoach" integer,
    "rateAfterDiscount" double precision,
    "rateBeforeDiscount" double precision,
    "totalOrderAmount" double precision,
    "packingTemplate" jsonb,
    "itemType" text DEFAULT 'SIMPLE'::text NOT NULL,
    "hasSubItems" boolean DEFAULT false NOT NULL
);


ALTER TABLE public.master_items OWNER TO postgres;

--
-- Name: notifications; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.notifications (
    id text NOT NULL,
    title text NOT NULL,
    message text NOT NULL,
    type public."NotificationType" NOT NULL,
    "isRead" boolean DEFAULT false NOT NULL,
    "userId" text NOT NULL,
    "projectId" text,
    "lotId" text,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public.notifications OWNER TO postgres;

--
-- Name: project_departments; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.project_departments (
    id text NOT NULL,
    "projectId" text NOT NULL,
    "departmentId" text NOT NULL
);


ALTER TABLE public.project_departments OWNER TO postgres;

--
-- Name: projects; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.projects (
    id text NOT NULL,
    title text NOT NULL,
    "poNumber" text NOT NULL,
    "startDate" timestamp(3) without time zone NOT NULL,
    "endDate" timestamp(3) without time zone NOT NULL,
    "tenderDate" timestamp(3) without time zone NOT NULL,
    status public."ProjectStatus" DEFAULT 'ACTIVE'::public."ProjectStatus" NOT NULL,
    progress double precision DEFAULT 0 NOT NULL,
    "totalValue" double precision NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL,
    "managerId" text NOT NULL,
    "categoryId" text,
    "clientId" text,
    "inspectionAgencyId" text
);


ALTER TABLE public.projects OWNER TO postgres;

--
-- Name: stakeholders; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.stakeholders (
    id text NOT NULL,
    name text NOT NULL,
    "isActive" boolean DEFAULT true NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE public.stakeholders OWNER TO postgres;

--
-- Name: suppliers; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.suppliers (
    id text NOT NULL,
    name text NOT NULL,
    email text,
    "isActive" boolean DEFAULT true NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE public.suppliers OWNER TO postgres;

--
-- Name: users; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.users (
    id text NOT NULL,
    email text NOT NULL,
    name text,
    password text NOT NULL,
    role public."UserRole" DEFAULT 'PROJECT_MANAGER'::public."UserRole" NOT NULL,
    department text,
    "isActive" boolean DEFAULT true NOT NULL,
    "twoFactorEnabled" boolean DEFAULT false NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL,
    "gmailTokens" jsonb
);


ALTER TABLE public.users OWNER TO postgres;

--
-- Data for Name: audit_logs; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.audit_logs (id, action, entity, "entityId", "oldValues", "newValues", "userId", "projectId", "lotId", "createdAt", "invoiceId") FROM stdin;
cmfqjpxnz000tky04n3e43ksb	DOCUMENT_RECEIVED_EMAIL	Document	cmfl2c9fz000gjp04z4a03ifp	{"status": "PENDING", "placeholder": true}	{"s3Key": "projects/pg/dtl/2024-22/op/17/lots/lot-001/departments/calibration/documents/calibration_certificate/statement/2025-09-19T07-56-28-334Z_calibration_certificate.pdf", "s3Path": "PG/DTL/2024-22/OP/17/LOT-001/Calibration", "status": "RECEIVED", "fileSize": 2505273, "filename": "calibration certificate.pdf", "senderEmail": "Ayush Som <ayush.web03@gmail.com>", "matchedViaEmail": true, "originalRequirement": "Calibration Certificate/Statement"}	cmeve8gys0000s46d6wank1vs	\N	cmfl2c9dx0001jp04u9tl1048	2025-09-19 07:56:28.463	\N
cmfkyzweb0001l404wsusy192	GMAIL_AUTHORIZED	User	cmeve8gys0000s46d6wank1vs	\N	{"userEmail": "sachinsinghmtqm@gmail.com", "authorizedAt": "2025-09-15T10:17:30.562Z", "hasRefreshToken": true}	cmeve8gys0000s46d6wank1vs	\N	\N	2025-09-15 10:17:30.563	\N
cmfkzc1ol0003i804dcvuahti	PROJECT_CREATED	Project	cmfkzc1o50001i804mtuty789	\N	{"client": "Matunga", "poNumber": "PG/DTL/2024-22/OP/17", "createdAt": "2025-09-15T10:26:57.284Z", "projectName": "Comprehensive Maintenance Contract of RMPU of ICF  AC coaches at Matunga Workshop,  Qty-600 coaches for period of 02 years"}	cmeve8gys0000s46d6wank1vs	\N	\N	2025-09-15 10:26:57.285	\N
cmfkzc3w3001ii804prwx0zzs	DOCUMENT_INTELLIGENT_PROCESSED	Document	cmfkzc2vj0007i8045uclio96	\N	{"documentName": "AMC Matunga POH 2025-2026 Summary updated 08.09.25 .xlsx", "documentType": "SUMMARY_SHEET", "processingTime": "2025-09-15T10:27:00.146Z", "masterItemsCount": 39, "processingStatus": "COMPLETED", "requirementsCount": 0, "processingDuration": 1290}	cmeve8gys0000s46d6wank1vs	\N	\N	2025-09-15 10:27:00.147	\N
cmfkzcfm1001yi804530qjb27	DOCUMENT_INTELLIGENT_PROCESSED	Document	cmfkzc3e4001ei804bv50udvi	\N	{"documentName": "Top Sheet RITES Inspection.pdf", "documentType": "TOP_SHEET", "processingTime": "2025-09-15T10:27:15.336Z", "masterItemsCount": 0, "processingStatus": "COMPLETED", "requirementsCount": 12, "processingDuration": 15830}	cmeve8gys0000s46d6wank1vs	\N	\N	2025-09-15 10:27:15.337	\N
cmfl2c9g7000kjp04vwm6ylm9	LOT_CREATED	Lot	cmfl2c9dx0001jp04u9tl1048	\N	{"createdAt": "2025-09-15T11:51:06.199Z", "itemCount": 9, "lotNumber": "LOT-001", "totalValue": 1519063.832, "projectName": "Comprehensive Maintenance Contract of RMPU of ICF  AC coaches at Matunga Workshop,  Qty-600 coaches for period of 02 years", "hasRevisions": false, "stakeholderName": "Sachin Kumar Singh", "customDocumentCount": 1, "templateDocumentCount": 7}	cmeve8gys0000s46d6wank1vs	cmfkzc1o50001i804mtuty789	cmfl2c9dx0001jp04u9tl1048	2025-09-15 11:51:06.2	\N
cmfl2c9ud000mjp04jdsiv1qe	LOT_EMAILS_SENT	Lot	cmfl2c9dx0001jp04u9tl1048	\N	{"errors": null, "sentAt": "2025-09-15T11:51:06.709Z", "emailsSent": 2, "departments": ["AMC", "Calibration"], "emailsFailed": 0}	cmeve8gys0000s46d6wank1vs	cmfkzc1o50001i804mtuty789	cmfl2c9dx0001jp04u9tl1048	2025-09-15 11:51:06.71	\N
cmfqjpv1v000jky04xlfdr9bi	DOCUMENT_RECEIVED_EMAIL	Document	cmfl2c9fy000djp04aogc3x3h	{"status": "PENDING", "placeholder": true}	{"s3Key": "projects/pg/dtl/2024-22/op/17/lots/lot-001/departments/amc/documents/drawing/specifications/2025-09-19T07-56-24-950Z_drawing_specification.pdf", "s3Path": "PG/DTL/2024-22/OP/17/LOT-001/AMC", "status": "RECEIVED", "fileSize": 1591363, "filename": " Drawing Specification.pdf", "senderEmail": "Ryzen _1 <ryzensingh@gmail.com>", "matchedViaEmail": true, "originalRequirement": "Drawing/Specifications"}	cmeve8gys0000s46d6wank1vs	\N	cmfl2c9dx0001jp04u9tl1048	2025-09-19 07:56:25.075	\N
cmfqjpvbx000rky044z7tnc0u	EMAIL_PROCESSED	Email	19960f8a8fdc9e8c	\N	{"errors": [], "status": "PROCESSED", "processedAt": "2025-09-19T07:56:25.437Z", "senderEmail": "Ryzen _1 <ryzensingh@gmail.com>", "processedViaGmail": true}	cmeve8gys0000s46d6wank1vs	\N	cmfl2c9dx0001jp04u9tl1048	2025-09-19 07:56:25.438	\N
cmfl2d2ke0001l2044fajchf9	LOT_COMPREHENSIVE_UPDATE	Lot	cmfl2c9dx0001jp04u9tl1048	{"notes": null, "lotNumber": "LOT-001", "timestamp": "2025-09-15T11:51:43.933Z", "inspectionDate": "2025-04-25T00:00:00.000Z"}	{"notes": "", "editType": "COMPREHENSIVE_UPDATE", "editedBy": "Admin User", "lotNumber": "LOT-001", "timestamp": "2025-09-15T11:51:43.933Z", "changeDetails": {"changes": {"items": {"added": [], "removed": [], "updated": [{"itemId": "cmfl2c9eu0002jp04mvtyjod8", "changes": {"internalDetails": {"new": "", "old": null}}, "masterItemId": "cmfkzc2zv000ai804iyo62z89", "masterItemDescription": "Supply and Replacement of anti- vibration mounting (AVM) pads of RMPU unit."}, {"itemId": "cmfl2c9eu0003jp04dn1s0pr4", "changes": {"internalDetails": {"new": "", "old": null}}, "masterItemId": "cmfkzc2zv000bi804nveybj6u", "masterItemDescription": "Supply and Replacement of fresh and Return air filter(1 set consist of 4 fresh Air Filter and 4 nos. Return Air Filter.)"}, {"itemId": "cmfl2c9eu0004jp04ku90jppk", "changes": {"internalDetails": {"new": "", "old": null}}, "masterItemId": "cmfkzc2zv000ci804ys0jru45", "masterItemDescription": "Supply & fixing of set of new fresh air and return air duct removing the old ducts (1 Coach set - 2 nos. consist of supply air duct and 4 Nos. of return air\\r\\nduct), Note: 1 set consists of 5 meter Canvas cloth"}, {"itemId": "cmfl2c9eu0005jp04c6ycud3w", "changes": {"internalDetails": {"new": "", "old": null}}, "masterItemId": "cmfkzc2zv000xi804kfd3tg41", "masterItemDescription": "Supply and replacement of Low pressure control Cut- out/switch"}, {"itemId": "cmfl2c9eu0006jp04weufwald", "changes": {"internalDetails": {"new": "", "old": null}}, "masterItemId": "cmfkzc2zv000yi8042h1xu6wb", "masterItemDescription": "Supply and replacement of High pressure control cut- out/switch"}, {"itemId": "cmfl2c9eu0007jp04buqbuahd", "changes": {"internalDetails": {"new": "", "old": null}}, "masterItemId": "cmfkzc2zv000zi804dfinpzc0", "masterItemDescription": "Supply of  Electronic Time Delay Relay"}, {"itemId": "cmfl2c9eu0008jp04lalf6i9t", "changes": {"internalDetails": {"new": "", "old": null}}, "masterItemId": "cmfkzc2zw0014i804fy3m9d9w", "masterItemDescription": "Supply of MPCB for Compressor WITH AUXILIARY CONTACTS 1 NO + 1\\r\\nNC SIDE MOUNTING."}, {"itemId": "cmfl2c9eu0009jp0422f4r90q", "changes": {"internalDetails": {"new": "", "old": null}}, "masterItemId": "cmfkzc2zw0015i804u34wz5to", "masterItemDescription": "Supply of MPCB for Condenser WITH AUXILIARY CONTACTS 1 NO + 1\\r\\nNC SIDE MOUNTING."}, {"itemId": "cmfl2c9eu000ajp04ow8rf0vc", "changes": {"internalDetails": {"new": "", "old": null}}, "masterItemId": "cmfkzc2zw001ci804akze6wla", "masterItemDescription": "Supply of blower motor runner."}]}, "notes": {"new": "", "old": null}, "inspectionDate": {"new": "2025-09-15T00:00:00.000Z", "old": "2025-04-25T00:00:00.000Z"}, "documentsUpdated": {"count": 8, "reason": "Inspection date change", "newInspectionDate": "2025-09-15T00:00:00.000Z"}, "documentGenerationRequested": {"instant": true, "requestedAt": "2025-09-15T11:51:43.891Z", "inspectionDate": "2025-09-15T00:00:00.000Z"}}, "editType": "COMPREHENSIVE_UPDATE", "editedBy": "Admin User", "timestamp": "2025-09-15T11:51:43.887Z"}, "inspectionDate": "2025-09-15T00:00:00.000Z"}	cmeve8gys0000s46d6wank1vs	cmfkzc1o50001i804mtuty789	\N	2025-09-15 11:51:43.935	\N
cmfl2d8dn000bl2049nfvnwac	DOCUMENTS_GENERATED	Lot	cmfl2c9dx0001jp04u9tl1048	\N	"{\\"documentsGenerated\\":[\\"OFFER_LETTER_PDF\\",\\"PACKING_LIST_PDF\\",\\"WARRANTY_CERTIFICATE_PDF\\",\\"INTERNAL_TEST_REPORT_PDF\\"],\\"generatedAt\\":\\"2025-09-15T11:51:51.466Z\\",\\"s3Keys\\":[\\"projects/PG/DTL/2024-22/OP/17/lots/LOT-001/generated/offer_letter_LOT-001.pdf\\",\\"projects/PG/DTL/2024-22/OP/17/lots/LOT-001/generated/packing_list_LOT-001.pdf\\",\\"projects/PG/DTL/2024-22/OP/17/lots/LOT-001/generated/warranty_certificate_LOT-001.pdf\\",\\"projects/PG/DTL/2024-22/OP/17/lots/LOT-001/generated/internal_test_report_LOT-001.pdf\\"],\\"format\\":\\"PDF\\"}"	cmeve8gys0000s46d6wank1vs	cmfkzc1o50001i804mtuty789	cmfl2c9dx0001jp04u9tl1048	2025-09-15 11:51:51.467	\N
cmfl2ekti0001jr04i4kn4pds	DOCUMENT_EDITED	Document	cmfl2d8dj0009l204g6dq2rny	"{\\"fileSize\\":24548,\\"extractedText\\":\\"{\\\\\\"date\\\\\\":\\\\\\"15-09-2025\\\\\\",\\\\\\"itemDescription\\\\\\":\\\\\\"LOA for the work 'Comprehensive Maintenance Contract of RMPU of ICF Coaches at Mumbai Workshop'\\\\\\",\\\\\\"loaNumber\\\\\\":\\\\\\"CE-Shop-MTN-Electrical-PG-DTL-2024-25-OP-17/00617230125201\\\\\\",\\\\\\"loaDate\\\\\\":\\\\\\"15-09-2025\\\\\\",\\\\\\"maNumber\\\\\\":\\\\\\"NIL\\\\\\",\\\\\\"quantityDescription\\\\\\":\\\\\\"List of spare parts for RITES Inspection for POH of RMPU's of ICF AC\\\\\\",\\\\\\"quantityDetails\\\\\\":\\\\\\"Letter ref.# PG/DTL/2024-25/OP/17\\\\\\",\\\\\\"alreadyInspected\\\\\\":\\\\\\"0\\\\\\",\\\\\\"consigneeName\\\\\\":\\\\\\"Dy. CEE/G, Electrical Branch, Carriage Workshop, Matunga, Mumbai\\\\\\",\\\\\\"consigneeAddress\\\\\\":\\\\\\"400019, Maharashtra, India\\\\\\",\\\\\\"items\\\\\\":[{\\\\\\"serialNumber\\\\\\":\\\\\\"1\\\\\\",\\\\\\"description\\\\\\":\\\\\\"Supply and Replacement of anti- vibration mounting (AVM) pads of RMPU unit.\\\\\\",\\\\\\"unit\\\\\\":\\\\\\"Nos.\\\\\\",\\\\\\"quantity\\\\\\":600,\\\\\\"make\\\\\\":\\\\\\"Resistoflex\\\\\\"},{\\\\\\"serialNumber\\\\\\":\\\\\\"2\\\\\\",\\\\\\"description\\\\\\":\\\\\\"Supply and Replacement of fresh and Return air filter(1 set consist of 4 fresh Air Filter and 4 nos. Return Air Filter.)\\\\\\",\\\\\\"unit\\\\\\":\\\\\\"Set\\\\\\",\\\\\\"quantity\\\\\\":50,\\\\\\"make\\\\\\":\\\\\\"usha\\\\\\"},{\\\\\\"serialNumber\\\\\\":\\\\\\"3\\\\\\",\\\\\\"description\\\\\\":\\\\\\"Supply & fixing of set of new fresh air and return air duct removing the old ducts (1 Coach set - 2 nos. consist of supply air duct and 4 Nos. of return air\\\\\\\\r\\\\\\\\nduct), Note: 1 set consists of 5 meter Canvas cloth\\\\\\",\\\\\\"unit\\\\\\":\\\\\\"Set\\\\\\",\\\\\\"quantity\\\\\\":60,\\\\\\"make\\\\\\":\\\\\\"Delkon\\\\\\"},{\\\\\\"serialNumber\\\\\\":\\\\\\"24\\\\\\",\\\\\\"description\\\\\\":\\\\\\"Supply and replacement of Low pressure control Cut- out/switch\\\\\\",\\\\\\"unit\\\\\\":\\\\\\"Nos.\\\\\\",\\\\\\"quantity\\\\\\":100,\\\\\\"make\\\\\\":\\\\\\"Danfoss\\\\\\"},{\\\\\\"serialNumber\\\\\\":\\\\\\"25\\\\\\",\\\\\\"description\\\\\\":\\\\\\"Supply and replacement of High pressure control cut- out/switch\\\\\\",\\\\\\"unit\\\\\\":\\\\\\"Nos.\\\\\\",\\\\\\"quantity\\\\\\":100,\\\\\\"make\\\\\\":\\\\\\"Danfoss\\\\\\"},{\\\\\\"serialNumber\\\\\\":\\\\\\"26\\\\\\",\\\\\\"description\\\\\\":\\\\\\"Supply of  Electronic Time Delay Relay\\\\\\",\\\\\\"unit\\\\\\":\\\\\\"Nos\\\\\\",\\\\\\"quantity\\\\\\":40,\\\\\\"make\\\\\\":\\\\\\"MAX MICRO SYSTEMS\\\\\\"},{\\\\\\"serialNumber\\\\\\":\\\\\\"31\\\\\\",\\\\\\"description\\\\\\":\\\\\\"Supply of MPCB for Compressor WITH AUXILIARY CONTACTS 1 NO + 1\\\\\\\\r\\\\\\\\nNC SIDE MOUNTING.\\\\\\",\\\\\\"unit\\\\\\":\\\\\\"Nos.\\\\\\",\\\\\\"quantity\\\\\\":20,\\\\\\"make\\\\\\":\\\\\\"BCH\\\\\\"},{\\\\\\"serialNumber\\\\\\":\\\\\\"32\\\\\\",\\\\\\"description\\\\\\":\\\\\\"Supply of MPCB for Condenser WITH AUXILIARY CONTACTS 1 NO + 1\\\\\\\\r\\\\\\\\nNC SIDE MOUNTING.\\\\\\",\\\\\\"unit\\\\\\":\\\\\\"Nos.\\\\\\",\\\\\\"quantity\\\\\\":20,\\\\\\"make\\\\\\":\\\\\\"BCH\\\\\\"},{\\\\\\"serialNumber\\\\\\":\\\\\\"39\\\\\\",\\\\\\"description\\\\\\":\\\\\\"Supply of blower motor runner.\\\\\\",\\\\\\"unit\\\\\\":\\\\\\"Set\\\\\\",\\\\\\"quantity\\\\\\":60,\\\\\\"make\\\\\\":\\\\\\"Blowtech\\\\\\"}]}\\"}"	"{\\"fileSize\\":24550,\\"extractedText\\":\\"{\\\\\\"date\\\\\\":\\\\\\"25/04/2025\\\\\\",\\\\\\"itemDescription\\\\\\":\\\\\\"LOA for the work 'Comprehensive Maintenance Contract of RMPU of ICF Coaches at Mumbai Workshop'\\\\\\",\\\\\\"loaNumber\\\\\\":\\\\\\"CE-Shop-MTN-Electrical-PG-DTL-2024-25-OP-17/00617230125201\\\\\\",\\\\\\"loaDate\\\\\\":\\\\\\"25/03/2025\\\\\\",\\\\\\"maNumber\\\\\\":\\\\\\"NIL\\\\\\",\\\\\\"quantityDescription\\\\\\":\\\\\\"List of spare parts for RITES Inspection for POH of RMPU's of ICF AC\\\\\\",\\\\\\"quantityDetails\\\\\\":\\\\\\"Letter ref.# PG/DTL/2024-25/OP/17\\\\\\",\\\\\\"alreadyInspected\\\\\\":\\\\\\"0\\\\\\",\\\\\\"consigneeName\\\\\\":\\\\\\"Dy. CEE/G, Electrical Branch, Carriage Workshop, Matunga, Mumbai\\\\\\",\\\\\\"consigneeAddress\\\\\\":\\\\\\"400019, Maharashtra, India\\\\\\",\\\\\\"items\\\\\\":[{\\\\\\"serialNumber\\\\\\":\\\\\\"1\\\\\\",\\\\\\"description\\\\\\":\\\\\\"Supply and Replacement of anti- vibration mounting (AVM) pads of RMPU unit.\\\\\\",\\\\\\"unit\\\\\\":\\\\\\"Nos.\\\\\\",\\\\\\"quantity\\\\\\":600,\\\\\\"make\\\\\\":\\\\\\"Resistoflex\\\\\\"},{\\\\\\"serialNumber\\\\\\":\\\\\\"2\\\\\\",\\\\\\"description\\\\\\":\\\\\\"Supply and Replacement of fresh and Return air filter(1 set consist of 4 fresh Air Filter and 4 nos. Return Air Filter.)\\\\\\",\\\\\\"unit\\\\\\":\\\\\\"Set\\\\\\",\\\\\\"quantity\\\\\\":50,\\\\\\"make\\\\\\":\\\\\\"usha\\\\\\"},{\\\\\\"serialNumber\\\\\\":\\\\\\"3\\\\\\",\\\\\\"description\\\\\\":\\\\\\"Supply & fixing of set of new fresh air and return air duct removing the old ducts (1 Coach set - 2 nos. consist of supply air duct and 4 Nos. of return air\\\\\\\\r\\\\\\\\nduct), Note: 1 set consists of 5 meter Canvas cloth\\\\\\",\\\\\\"unit\\\\\\":\\\\\\"Set\\\\\\",\\\\\\"quantity\\\\\\":60,\\\\\\"make\\\\\\":\\\\\\"Delkon\\\\\\"},{\\\\\\"serialNumber\\\\\\":\\\\\\"24\\\\\\",\\\\\\"description\\\\\\":\\\\\\"Supply and replacement of Low pressure control Cut- out/switch\\\\\\",\\\\\\"unit\\\\\\":\\\\\\"Nos.\\\\\\",\\\\\\"quantity\\\\\\":100,\\\\\\"make\\\\\\":\\\\\\"Danfoss\\\\\\"},{\\\\\\"serialNumber\\\\\\":\\\\\\"25\\\\\\",\\\\\\"description\\\\\\":\\\\\\"Supply and replacement of High pressure control cut- out/switch\\\\\\",\\\\\\"unit\\\\\\":\\\\\\"Nos.\\\\\\",\\\\\\"quantity\\\\\\":100,\\\\\\"make\\\\\\":\\\\\\"Danfoss\\\\\\"},{\\\\\\"serialNumber\\\\\\":\\\\\\"26\\\\\\",\\\\\\"description\\\\\\":\\\\\\"Supply of  Electronic Time Delay Relay\\\\\\",\\\\\\"unit\\\\\\":\\\\\\"Nos\\\\\\",\\\\\\"quantity\\\\\\":40,\\\\\\"make\\\\\\":\\\\\\"MAX MICRO SYSTEMS\\\\\\"},{\\\\\\"serialNumber\\\\\\":\\\\\\"31\\\\\\",\\\\\\"description\\\\\\":\\\\\\"Supply of MPCB for Compressor WITH AUXILIARY CONTACTS 1 NO + 1\\\\\\\\r\\\\\\\\nNC SIDE MOUNTING.\\\\\\",\\\\\\"unit\\\\\\":\\\\\\"Nos.\\\\\\",\\\\\\"quantity\\\\\\":20,\\\\\\"make\\\\\\":\\\\\\"BCH\\\\\\"},{\\\\\\"serialNumber\\\\\\":\\\\\\"32\\\\\\",\\\\\\"description\\\\\\":\\\\\\"Supply of MPCB for Condenser WITH AUXILIARY CONTACTS 1 NO + 1\\\\\\\\r\\\\\\\\nNC SIDE MOUNTING.\\\\\\",\\\\\\"unit\\\\\\":\\\\\\"Nos.\\\\\\",\\\\\\"quantity\\\\\\":20,\\\\\\"make\\\\\\":\\\\\\"BCH\\\\\\"},{\\\\\\"serialNumber\\\\\\":\\\\\\"39\\\\\\",\\\\\\"description\\\\\\":\\\\\\"Supply of blower motor runner.\\\\\\",\\\\\\"unit\\\\\\":\\\\\\"Set\\\\\\",\\\\\\"quantity\\\\\\":60,\\\\\\"make\\\\\\":\\\\\\"Blowtech\\\\\\"}]}\\",\\"editedFields\\":[\\"date\\",\\"itemDescription\\",\\"loaNumber\\",\\"loaDate\\",\\"maNumber\\",\\"quantityDescription\\",\\"quantityDetails\\",\\"alreadyInspected\\",\\"consigneeName\\",\\"consigneeAddress\\",\\"items\\"]}"	cmeve8gys0000s46d6wank1vs	cmfkzc1o50001i804mtuty789	cmfl2c9dx0001jp04u9tl1048	2025-09-15 11:52:54.246	\N
cmfl2wbk30005jp04n6tvuh48	DOCUMENT_REMINDER_SENT	Lot	cmfl2c9dx0001jp04u9tl1048	\N	{"results": [{"emails": ["ryzensingh@gmail.com"], "status": "sent", "department": "AMC", "daysPending": 1, "pendingDocuments": 7}, {"emails": ["ayush.web03@gmail.com"], "status": "sent", "department": "Calibration", "daysPending": 1, "pendingDocuments": 1}], "departments": ["AMC", "Calibration"], "reminderType": "standard"}	cmeve8gys0000s46d6wank1vs	\N	cmfl2c9dx0001jp04u9tl1048	2025-09-15 12:06:42.052	\N
cmfqjpnma0001ky04jp5y5ohw	EMAIL_MONITOR_MONITORING_STARTED	EmailMonitor	automated-monitor	\N	{"stats": {"errors": 0, "lastCheckAt": "2025-09-19T07:56:15.189Z", "totalChecks": 0, "activeLotsMonitored": 0, "totalEmailsProcessed": 0, "averageProcessingTime": 0, "totalDocumentsReceived": 0}, "timestamp": "2025-09-19T07:56:15.441Z", "gmailEmail": "sachinsinghmtqm@gmail.com", "automatedSystem": true, "intervalMinutes": 5, "maxEmailsPerBatch": 20}	cmeve8gys0000s46d6wank1vs	\N	\N	2025-09-19 07:56:15.442	\N
cmfqjpuks0005ky04zb8tywyl	DOCUMENT_RECEIVED_EMAIL	Document	cmfl2c9fz000fjp045sxcmeno	{"status": "PENDING", "placeholder": true}	{"s3Key": "projects/pg/dtl/2024-22/op/17/lots/lot-001/departments/amc/documents/internal_test_records/2025-09-19T07-56-24-310Z_internaltest_record.pdf", "s3Path": "PG/DTL/2024-22/OP/17/LOT-001/AMC", "status": "RECEIVED", "fileSize": 227975, "filename": "InternalTest Record.pdf", "senderEmail": "Ryzen _1 <ryzensingh@gmail.com>", "matchedViaEmail": true, "originalRequirement": "Internal Test Records"}	cmeve8gys0000s46d6wank1vs	\N	cmfl2c9dx0001jp04u9tl1048	2025-09-19 07:56:24.461	\N
cmfqjpul90007ky04tti7lw2f	LOT_STATUS_UPDATE_EMAIL	Lot	cmfl2c9dx0001jp04u9tl1048	{"status": "CREATED", "progress": 0}	{"reason": "Documents received via email processing", "status": "DOCUMENTS_PENDING", "progress": 29, "totalDocuments": 12, "receivedDocuments": 5}	cmeve8gys0000s46d6wank1vs	\N	cmfl2c9dx0001jp04u9tl1048	2025-09-19 07:56:24.477	\N
cmfqjpus0000bky042u1l92yn	DOCUMENT_RECEIVED_EMAIL	Document	cmfl2c9fy000ejp04x8egeo3o	{"status": "PENDING", "placeholder": true}	{"s3Key": "projects/pg/dtl/2024-22/op/17/lots/lot-001/departments/amc/documents/checksheet_inspection_data/2025-09-19T07-56-24-553Z_checksheet_and_inspection_data.pdf", "s3Path": "PG/DTL/2024-22/OP/17/LOT-001/AMC", "status": "RECEIVED", "fileSize": 1274781, "filename": "checksheet and inspection data.pdf", "senderEmail": "Ryzen _1 <ryzensingh@gmail.com>", "matchedViaEmail": true, "originalRequirement": "Checksheet & Inspection Data"}	cmeve8gys0000s46d6wank1vs	\N	cmfl2c9dx0001jp04u9tl1048	2025-09-19 07:56:24.72	\N
cmfqjpuwm000fky04vo4lp64p	DOCUMENT_RECEIVED_EMAIL	Document	cmfl2c9fy000bjp04eavexwb3	{"status": "PENDING", "placeholder": true}	{"s3Key": "projects/pg/dtl/2024-22/op/17/lots/lot-001/departments/amc/documents/call_letter/2025-09-19T07-56-24-761Z_call_letter.pdf", "s3Path": "PG/DTL/2024-22/OP/17/LOT-001/AMC", "status": "RECEIVED", "fileSize": 1541035, "filename": "call letter.pdf", "senderEmail": "Ryzen _1 <ryzensingh@gmail.com>", "matchedViaEmail": true, "originalRequirement": "Call Letter"}	cmeve8gys0000s46d6wank1vs	\N	cmfl2c9dx0001jp04u9tl1048	2025-09-19 07:56:24.887	\N
cmfqjpv62000nky040xr1mq5k	DOCUMENT_RECEIVED_EMAIL	Document	cmfl2c9fy000cjp04s6zfb4kr	{"status": "PENDING", "placeholder": true}	{"s3Key": "projects/pg/dtl/2024-22/op/17/lots/lot-001/departments/amc/documents/po_copy_with_amendments/2025-09-19T07-56-25-109Z_po_copy_with_amendments.pdf", "s3Path": "PG/DTL/2024-22/OP/17/LOT-001/AMC", "status": "RECEIVED", "fileSize": 2455876, "filename": "PO copy with amendments.pdf", "senderEmail": "Ryzen _1 <ryzensingh@gmail.com>", "matchedViaEmail": true, "originalRequirement": "PO Copy with Amendments"}	cmeve8gys0000s46d6wank1vs	\N	cmfl2c9dx0001jp04u9tl1048	2025-09-19 07:56:25.226	\N
cmfqjpxtr000xky044yt4mveu	EMAIL_PROCESSED	Email	19960de63bb3caac	\N	{"errors": [], "status": "PROCESSED", "processedAt": "2025-09-19T07:56:28.670Z", "senderEmail": "Ayush Som <ayush.web03@gmail.com>", "processedViaGmail": true}	cmeve8gys0000s46d6wank1vs	\N	cmfl2c9dx0001jp04u9tl1048	2025-09-19 07:56:28.671	\N
cmfqjpxua0013ky04d6znpk06	EMAIL_MONITOR_EMAILS_PROCESSED	EmailMonitor	automated-monitor	\N	{"stats": {"errors": 0, "lastCheckAt": "2025-09-19T07:56:28.675Z", "totalChecks": 1, "activeLotsMonitored": 1, "totalEmailsProcessed": 2, "averageProcessingTime": 8224, "totalDocumentsReceived": 6}, "results": [{"lotId": "cmfl2c9dx0001jp04u9tl1048", "subject": "Re: Document Request - Comprehensive Maintenance Contract of RMPU of ICF AC coaches at Matunga Workshop, Qty-600 coaches for period of 02 years - LOT-001 - AMC Documents", "success": true, "messageId": "19960f8a8fdc9e8c", "documentsProcessed": 5}, {"lotId": "cmfl2c9dx0001jp04u9tl1048", "subject": "Re: Document Request - Comprehensive Maintenance Contract of RMPU of ICF AC coaches at Matunga Workshop, Qty-600 coaches for period of 02 years - LOT-001 - Calibration Documents", "success": true, "messageId": "19960de63bb3caac", "documentsProcessed": 1}], "timestamp": "2025-09-19T07:56:28.689Z", "activeLots": 1, "totalEmails": 2, "automatedSystem": true, "processingTimeMs": 8224, "successfulEmails": 2, "documentsReceived": 6}	cmeve8gys0000s46d6wank1vs	\N	\N	2025-09-19 07:56:28.69	\N
\.


--
-- Data for Name: categories; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.categories (id, name, "isActive", "createdAt", "updatedAt") FROM stdin;
cmex4mi6r0000la04c3r0zukl	ICDOOR	t	2025-08-29 17:48:35.091	2025-09-12 05:28:14.517
cmeve8k2y0007s46dkqkav6vs	SPARE	t	2025-08-28 12:42:08.17	2025-09-12 05:28:14.517
cmeve8jmt0006s46de5vch8pb	RMPU	t	2025-08-28 12:42:07.59	2025-09-12 05:28:14.517
cmfkrqof20000l50418rl9shb	AMC	t	2025-09-15 06:54:23.004	2025-09-15 06:54:23.004
\.


--
-- Data for Name: clients; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.clients (id, name, email, "isActive", "createdAt", "updatedAt") FROM stdin;
cmeve8kyy0009s46dtlw9jept	Northern Railway	northern@indianrailways.gov.in	t	2025-08-28 12:42:09.016	2025-09-12 05:28:14.517
cmeve8kan0008s46dm0jjyk3j	ICF	icf@indianrailways.gov.in	f	2025-08-28 12:42:08.448	2025-09-15 06:54:30.202
cmfkz62xg0000l404u4gn20y1	Matunga	\N	t	2025-09-15 10:22:18.963	2025-09-15 10:22:18.963
\.


--
-- Data for Name: departments; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.departments (id, name, code, emails, "contactPerson", "isActive", "createdAt", "updatedAt") FROM stdin;
cmfkrl3gr0000jw04bynvvfjs	AMC	AMC	{ryzensingh@gmail.com}	AMC manager	t	2025-09-15 06:50:02.571	2025-09-15 09:04:46.166
cmfkrnh3l0000jw047ueklotq	Calibration	CD	{ayush.web03@gmail.com}	Mrs. Alka	t	2025-09-15 06:51:53.553	2025-09-15 09:04:57.029
cmfkrkddz0000jw04ftj3bgeu	Store	ST	{ayushsom82@gmail.com}	Store manager	t	2025-09-15 06:49:28.775	2025-09-15 09:05:06.893
cmfl29mql0000jr04jsmofz6z	Quality	QC	{ayush.web03@gmail.com}	Ayush	t	2025-09-15 11:49:03.454	2025-09-15 11:49:42.951
\.


--
-- Data for Name: document_alternatives; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.document_alternatives (id, "projectId", "primaryDocumentRequirementId", "alternativeName", "matchPatterns", "isActive", "createdAt", "updatedAt") FROM stdin;
\.


--
-- Data for Name: document_requirements; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.document_requirements (id, "projectDepartmentId", name, description, "serialNumberRange", "isMandatory", "isActive", "createdAt", "updatedAt") FROM stdin;
\.


--
-- Data for Name: documents; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.documents (id, filename, "originalName", "filePath", "fileSize", "mimeType", status, "receivedAt", "processedAt", "extractedText", "aiAnalysis", "projectId", "lotId", "departmentId", "requirementId", "uploadedById", "createdAt", "updatedAt", "documentRequirementId", "documentType", "hasRedactedVersion", "invoiceDate", "invoiceNumber", "isVendorInvoice", "masterItemId", "originalDocumentId", "redactedDocumentId", "subItemIndex", "subItemName", "vendorName") FROM stdin;
cmfkzc3e4001ei804bv50udvi	1757932019363_Top_Sheet_RITES_Inspection.pdf	Top Sheet RITES Inspection.pdf	https://matunga-documents-ayush-som.s3.us-east-1.amazonaws.com/documents/projects/cmfkzc1o50001i804mtuty789/lots/no-lot/general/1757932019363_Top_Sheet_RITES_Inspection.pdf	506863	application/pdf	PROCESSED	\N	2025-09-15 10:27:14.325	TRITES ISO 9001 2015 TITLE: ISO/IEC 17020 2012 ISSUE NO 01 THE INFRASTRUCTURE PEOPLE FORMAT FOR TOP SHEET QUALITY ASSURANCE DIVISION who APPROVED DIVISIONAL HEAD FORMAT NO F/7 5/1/6 PAGE REV NO NIL EFFECTIVE DATE 6 APR 2018 FORMAT NO F/7 5/1/6 TOP SHEET RITES LIMITED, NORTHERN REGION 1. Case No. : 2. Name of Vendor/Manufacturer : 3. Description of Stores  Quantity : 4. Date(s) of Inspection : 5. IC No. and Date : 6. Sampling Method : 7. Value of Material Inspected : 8. Rate  Amount of Inspection fee : 9. Test(s) done in external lab : 10. Test for which certificate accepted : 11. Documents Attached S.No. i. Inspection Certificate : ii. Call Letter : iii. PO Copy with Amendments : iv. Drawing/Specifications, if any : V. Call Cancellation, if any : vi. Checksheet  Inspection Data : vii. Lab Requisition, if any : viii. Lab Report, if any : ix. Internal Test Records : X. Calibration Certificate/Statement : (based on Calibration Certificates verified) xi. Vendors certificate, if any : xii. Photo : 12. Competency of testing personnel based on familiarity of test equipment  procedure : Yes/No 13. Only standard testing procedures as per relevant specifications are used testing : Yes/No 14. Suitable equipment/facilities used for testing : Yes/No 15. Nature of Stamping Hologram/Steel/Rubber/Lead Sealing : 16. Special Remarks, if any (Signature of IE)	{"requirements":[{"name":"Inspection Certificate","description":"","serialNumberRange":"i","isMandatory":true,"department":"Unassigned"},{"name":"Call Letter","description":"","serialNumberRange":"ii","isMandatory":true,"department":"Unassigned"},{"name":"PO Copy with Amendments","description":"","serialNumberRange":"iii","isMandatory":true,"department":"Unassigned"},{"name":"Drawing/Specifications","description":"if any","serialNumberRange":"iv","isMandatory":true,"department":"Unassigned"},{"name":"Call Cancellation","description":"if any","serialNumberRange":"v","isMandatory":true,"department":"Unassigned"},{"name":"Checksheet & Inspection Data","description":"","serialNumberRange":"vi","isMandatory":true,"department":"Unassigned"},{"name":"Lab Requisition","description":"if any","serialNumberRange":"vii","isMandatory":true,"department":"Unassigned"},{"name":"Lab Report","description":"if any","serialNumberRange":"viii","isMandatory":true,"department":"Unassigned"},{"name":"Internal Test Records","description":"","serialNumberRange":"ix","isMandatory":true,"department":"Unassigned"},{"name":"Calibration Certificate/Statement","description":"based on Calibration Certificates verified","serialNumberRange":"x","isMandatory":true,"department":"Unassigned"},{"name":"Vendors certificate","description":"if any","serialNumberRange":"xi","isMandatory":true,"department":"Unassigned"},{"name":"Photo","description":"","serialNumberRange":"xii","isMandatory":true,"department":"Unassigned"}],"projectDetails":{"poNumber":"","title":"","client":"","inspectionAgency":"RITES LIMITED, NORTHERN REGION"},"summary":"Extracted 12 document requirements from top sheet"}	cmfkzc1o50001i804mtuty789	\N	\N	\N	cmeve8gys0000s46d6wank1vs	2025-09-15 10:26:59.501	2025-09-15 10:27:14.326	\N	REGULAR	f	\N	\N	f	\N	\N	\N	\N	\N	\N
cmfkzc2vj0007i8045uclio96	1757932018699_AMC_Matunga_POH_2025-2026_Summary_updated_08.09.25_.xlsx	AMC Matunga POH 2025-2026 Summary updated 08.09.25 .xlsx	https://matunga-documents-ayush-som.s3.us-east-1.amazonaws.com/documents/projects/cmfkzc1o50001i804mtuty789/lots/no-lot/general/1757932018699_AMC_Matunga_POH_2025-2026_Summary_updated_08.09.25_.xlsx	24622	application/vnd.openxmlformats-officedocument.spreadsheetml.sheet	PROCESSED	\N	2025-09-15 10:26:59.005	MASTER ITEMS SHEET: AMC Matunga POH  Extracted 39 master items directly Headers: loa sr. no. | description,part b :- list of spares | unit | qty./ coach | total qty. |  | total proposed | rate in rs. before discount | total supply | discount 11.60 | rate in rs. after discount | total order amount in rs. | lot1 qty. | lot1 amount | lot2 qty. | lot2 amount | lot3 qty. | lot3 amount | lot4 qty. | lot4 amount | dispatch qty. | remaining lot qty. | remaining lot amount | | purchase price / unit amt. | total purchase price amt. | profit/loss Item 1: Supply and Replacement of anti- vibration mounting (AVM) pads of RMPU unit. | 7200 Nos. | Rate: 761.4775999999999 | Total: 5482638.72 | Qty/Coach: 12 | : 1 Item 2: Supply and Replacement of fresh and Return air filter(1 set consist of 4 fresh Air Filter and 4 nos. Return Air Filter.) | 600 Set | Rate: 11630.788 | Total: 6978472.800000001 | Qty/Coach: 1 | : 1 Item 3: Supply  fixing of set of new fresh air and return air duct removing the old ducts (1 Coach set - 2 nos. consist of supply air duct and 4 Nos. of return air duct), Note: 1 set consists of 5 meter Canvas cloth | 600 Set | Rate: 1760.3092 | Total: 1056185.52 | Qty/Coach: 1 | : 1 Item 4: Replacement of blower motor. | 1200 Nos. | Rate: 0 | Qty/Coach: 2 | : 0.25 Item 5: Transportation, repair, rewinding, Supply and replacement of blower motor with runner | 1200 Nos. | Rate: 2057.97852 | Total: 1852180.668 | Qty/Coach: 2 | : 0.75 Item 6: Supply and Replacement of condenser motor . | 2400 Nos. | Rate: 7510.464 | Total: 4506278.4 | Qty/Coach: 4 | : 0.25 Item 7: Transportation, repair, rewinding, Supply and replacement of condenser motor with Fan Blade. | 2400 Nos. | Rate: 1967.0767999999998 | Total: 3540738.2399999998 | Qty/Coach: 4 | : 0.75 Item 8: Supply and Replacement of condensor Fan Blade with Aluminium Hub/fibre hub | 2400 Nos | Rate: 2659.956 | Total: 3191947.2 | Qty/Coach: 4 | : 0.5 Item 9: Supply and replacement of Evaporator coil (Left Hand or Right Hand as per field requirement) | 2400 Nos | Rate: 136728.86344000002 | Total: 1640746.3612800003 | Qty/Coach: 4 | : 0.01 Item 10: Supply and replacement of condenser coil (Left Hand or Right Hand as per field requirement) | 2400 Nos | Rate: 161954.83771999998 | Total: 1943458.05264 | Qty/Coach: 4 | : 0.01 Item 11: Supply and Replacement of scroll compressor suitable for R407 refrigerant. | 2400 Nos. | Rate: 40160.12 | Total: 4819214.4 | Qty/Coach: 4 | : 0.05 Item 12: Supply and Replacement of R407/R22 refrigerant in RMPU compressor | 9600 Kg | Rate: 419.12208 | Total: 2011785.984 | Qty/Coach: 16 | : 0.5 Item 13: Supply and Replacement of Thermostatic Expansion Valve | 2400 Nos | Rate: 1781.64896 | Total: 213797.8752 | Qty/Coach: 4 | : 0.05 Item 14: Supply and replacement Of ACCUMULATOR. | 2400 Nos. | Rate: 2165.9237599999997 | Total: 103964.34047999998 | Qty/Coach: 4 | : 0.02 Item 15: Supply and replacement Of suitable Drier filter | 2400 Nos | Rate: 356.74704 | Total: 85619.2896 | Qty/Coach: 4 | : 0.1 Item 16: Supply and replacement Of vane relay | 2400 Nos | Rate: 228.44328000000002 | Total: 274131.93600000005 | Qty/Coach: 4 | : 0.5 Item 17: Supply and replacement of complete 3KW Heater Assembly Set | 2400 Set | Rate: 1490.645 | Total: 536632.2 | Qty/Coach: 4 | : 0.15 Item 18: Supply and Replacement of power harness cable. | 1200 Nos. | Rate: 8712.925 | Total: 1568326.4999999998 | Qty/Coach: 2 | : 0.15 Item 19: Supply and replacement of Halting couplers including hood and base lever - 24 pin type | 1200 Nos. | Rate: 2298.55028 | Total: 275826.03359999997 | Qty/Coach: 2 | : 0.1 Item 20: Supply and Replacement of 37 pin Control cable plug with socket. | 1200 Nos. | Rate: 6747.12116 | Total: 809654.5392 | Qty/Coach: 2 | : 0.1 Item 21: Supply and replacement of Harting couplers including hood and base lever - 32 pin type | 1200 Nos. | Rate: 3395.87716 | Total: 203752.6296 | Qty/Coach: 2 | : 0.05 Item 22: Replacement of Solid state Temperature Controller(Electronic Thermostat) | 1200 Nos. | Rate: 0 | Qty/Coach: 2 | : 0.3 Item 23: Supply and replacement of defective/damaged over heat protection switch 15A, 250-300V, with fix setting at 65 DEGREE Celsius | 2400 Nos | Rate: 406.64 | Total: 585561.6 | Qty/Coach: 4 | : 0.6 Item 24: Supply and replacement of Low pressure control Cut- out/switch | 2400 Nos. | Rate: 726.90436 | Total: 697828.1856 | Qty/Coach: 4 | : 0.4 Item 25: Supply and replacement of High pressure control cut- out/switch | 2400 Nos. | Rate: 990.08 | Total: 1188096 | Qty/Coach: 4 | : 0.5 Item 26: Supply of Electronic Time Delay Relay | 1200 Nos | Rate: 2440.9008 | Total: 878724.288 | Qty/Coach: 2 | : 0.3 Item 27: Supply of PCB Board for AC Control Panel | 1200 Nos | Rate: 523.87608 | Total: 314325.648 | Qty/Coach: 2 | : 0.5 Item 28: Supply of 16 Amp Rotary switches for RSW 2 . | 600 Nos | Rate: 277.77048 | Total: 49998.686400000006 | Qty/Coach: 1 | : 0.3 Item 29: Supply of 16 Amp Rotary switches for RSW 3. | 600 Nos | Rate: 928.9602399999999 | Total: 167212.84319999997 | Qty/Coach: 1 | : 0.3 Item 30: Supply of 12 Amp Rotary switches for RSW 5. | 600 Nos | Rate: 315.74712 | Total: 9472.4136 | Qty/Coach: 1 | : 0.05 Item 31: Supply of MPCB for Compressor WITH AUXILIARY CONTACTS 1 NO  1 NC SIDE MOUNTING. | 2400 Nos. | Rate: 1758.34672 | Total: 1266009.6384 | Qty/Coach: 4 | : 0.3 Item 32: Supply of MPCB for Condenser WITH AUXILIARY CONTACTS 1 NO  1 NC SIDE MOUNTING. | 2400 Nos. | Rate: 896.1903599999999 | Total: 537714.216 | Qty/Coach: 4 | : 0.25 Item 33: Supply of MPCB for Blower with 1NO  1NC Auxillary Contact Block. | 1200 Nos. | Rate: 1322.7026799999999 | Total: 476172.96479999996 | Qty/Coach: 2 | : 0.3 Item 34: Supply of three pole 16 Amp MCB for Heater | 1200 Nos | Rate: 1603.34616 | Total: 577204.6176 | Qty/Coach: 2 | : 0.3 Item 35: Supply of three pole 63 Amp MCB | 1200 Nos | Rate: 1905.73604 | Total: 686064.9744 | Qty/Coach: 2 | : 0.3 Item 36: Supply of two pole 4 Amp/2Amp MCB. | 1200 Nos | Rate: 1128.67352 | Total: 406322.4672 | Qty/Coach: 2 | : 0.3 Item 37: Flushing the system with Nitrogen Gas and CTC cleaning. | 1200 Nos | Rate: 439.33916 | Total: 79081.0488 | Qty/Coach: 2 | : 0.15 Item 38: Supply of three pole 63 Amp Rotary Switches. | 1200 Nos. | Rate: 955.4979200000001 | Total: 401309.12640000007 | Qty/Coach: 2 | : 0.35 Item 39: Supply of blower motor runner. | 1200 Set | Rate: 10568.89184 | Total: 3170667.552 | Qty/Coach: 2 | : 0.25 --- End of AMC Matunga POH (39 items) ---	[{"serialNumber":1,"description":"Supply and Replacement of anti- vibration mounting (AVM) pads of RMPU unit.","unit":"Nos.","qtyPerCoach":12,"totalQuantity":7200,"percentage":1,"rateBeforeDiscount":861.4,"discountAmount":860.7315535999999,"discountPercentage":99.9224,"rateAfterDiscount":761.4775999999999,"totalOrderAmount":5482638.72,"rate":761.4775999999999,"supplier":""},{"serialNumber":2,"description":"Supply and Replacement of fresh and Return air filter(1 set consist of 4 fresh Air Filter and 4 nos. Return Air Filter.)","unit":"Set","qtyPerCoach":1,"totalQuantity":600,"percentage":1,"rateBeforeDiscount":13157,"discountAmount":200803.71284,"discountPercentage":1526.212,"rateAfterDiscount":11630.788,"totalOrderAmount":6978472.800000001,"rate":11630.788,"supplier":""},{"serialNumber":3,"description":"Supply & fixing of set of new fresh air and return air duct removing the old ducts (1 Coach set - 2 nos. consist of supply air duct and 4 Nos. of return air\\r\\nduct), Note: 1 set consists of 5 meter Canvas cloth","unit":"Set","qtyPerCoach":1,"totalQuantity":600,"percentage":1,"rateBeforeDiscount":1991.3,"discountAmount":4599.719800399999,"discountPercentage":230.99079999999998,"rateAfterDiscount":1760.3092,"totalOrderAmount":1056185.52,"rate":1760.3092,"supplier":""},{"serialNumber":4,"description":"Replacement of blower motor.","unit":"Nos.","qtyPerCoach":2,"totalQuantity":1200,"percentage":0.25,"rateBeforeDiscount":0,"discountAmount":0,"discountPercentage":0,"rateAfterDiscount":0,"totalOrderAmount":0,"rate":0,"supplier":""},{"serialNumber":5,"description":"Transportation,    repair, rewinding, Supply  and replacement  of  blower motor with runner","unit":"Nos.","qtyPerCoach":2,"totalQuantity":1200,"percentage":0.75,"rateBeforeDiscount":2328.03,"discountAmount":6286.8794698440015,"discountPercentage":270.05148,"rateAfterDiscount":2057.97852,"totalOrderAmount":1852180.668,"rate":2057.97852,"supplier":""},{"serialNumber":6,"description":"Supply and Replacement of condenser motor .","unit":"Nos.","qtyPerCoach":4,"totalQuantity":2400,"percentage":0.25,"rateBeforeDiscount":8496,"discountAmount":83731.13855999999,"discountPercentage":985.536,"rateAfterDiscount":7510.464,"totalOrderAmount":4506278.4,"rate":7510.464,"supplier":""},{"serialNumber":7,"description":"Transportation,    repair, rewinding, Supply       and replacement       of\\r\\ncondenser motor with Fan Blade.","unit":"Nos.","qtyPerCoach":4,"totalQuantity":2400,"percentage":0.75,"rateBeforeDiscount":2225.2,"discountAmount":5743.757446399998,"discountPercentage":258.12319999999994,"rateAfterDiscount":1967.0767999999998,"totalOrderAmount":3540738.2399999998,"rate":1967.0767999999998,"supplier":""},{"serialNumber":8,"description":"Supply and Replacement of condensor Fan Blade with Aluminium Hub/fibre\\r\\nhub","unit":"Nos","qtyPerCoach":4,"totalQuantity":2400,"percentage":0.5,"rateBeforeDiscount":3009,"discountAmount":10502.73396,"discountPercentage":349.044,"rateAfterDiscount":2659.956,"totalOrderAmount":3191947.2,"rate":2659.956,"supplier":""},{"serialNumber":9,"description":"Supply and replacement of Evaporator coil (Left Hand or Right Hand as per field requirement)","unit":"Nos","qtyPerCoach":4,"totalQuantity":2400,"percentage":0.01,"rateBeforeDiscount":154670.66,"discountAmount":27750695.15520929,"discountPercentage":17941.79656,"rateAfterDiscount":136728.86344000002,"totalOrderAmount":1640746.3612800003,"rate":136728.86344000002,"supplier":""},{"serialNumber":10,"description":"Supply and replacement of condenser coil (Left Hand or Right Hand as per field requirement)","unit":"Nos","qtyPerCoach":4,"totalQuantity":2400,"percentage":0.01,"rateBeforeDiscount":183206.83,"discountAmount":38935101.368032716,"discountPercentage":21251.99228,"rateAfterDiscount":161954.83771999998,"totalOrderAmount":1943458.05264,"rate":161954.83771999998,"supplier":""},{"serialNumber":11,"description":"Supply and Replacement of scroll compressor suitable for R407\\r\\nrefrigerant.","unit":"Nos.","qtyPerCoach":4,"totalQuantity":2400,"percentage":0.05,"rateBeforeDiscount":45430,"discountAmount":2394106.4839999997,"discountPercentage":5269.879999999999,"rateAfterDiscount":40160.12,"totalOrderAmount":4819214.4,"rate":40160.12,"supplier":""},{"serialNumber":12,"description":"Supply and Replacement of R407/R22 refrigerant in RMPU compressor","unit":"Kg","qtyPerCoach":16,"totalQuantity":9600,"percentage":0.5,"rateBeforeDiscount":474.12,"discountAmount":260.756138304,"discountPercentage":54.99791999999999,"rateAfterDiscount":419.12208,"totalOrderAmount":2011785.984,"rate":419.12208,"supplier":""},{"serialNumber":13,"description":"Supply and Replacement of Thermostatic Expansion Valve","unit":"Nos","qtyPerCoach":4,"totalQuantity":2400,"percentage":0.05,"rateBeforeDiscount":2015.44,"discountAmount":4711.918136576,"discountPercentage":233.79103999999998,"rateAfterDiscount":1781.64896,"totalOrderAmount":213797.8752,"rate":1781.64896,"supplier":""},{"serialNumber":14,"description":"Supply and replacement Of ACCUMULATOR.","unit":"Nos.","qtyPerCoach":4,"totalQuantity":2400,"percentage":0.02,"rateBeforeDiscount":2450.14,"discountAmount":6963.695782735998,"discountPercentage":284.21623999999997,"rateAfterDiscount":2165.9237599999997,"totalOrderAmount":103964.34047999998,"rate":2165.9237599999997,"supplier":""},{"serialNumber":15,"description":"Supply and replacement Of\\r\\nsuitable Drier filter","unit":"Nos","qtyPerCoach":4,"totalQuantity":2400,"percentage":0.1,"rateBeforeDiscount":403.56,"discountAmount":188.91838137599999,"discountPercentage":46.81296,"rateAfterDiscount":356.74704,"totalOrderAmount":85619.2896,"rate":356.74704,"supplier":""},{"serialNumber":16,"description":"Supply and replacement Of vane relay","unit":"Nos","qtyPerCoach":4,"totalQuantity":2400,"percentage":0.5,"rateBeforeDiscount":258.42,"discountAmount":77.465839824,"discountPercentage":29.97672,"rateAfterDiscount":228.44328000000002,"totalOrderAmount":274131.93600000005,"rate":228.44328000000002,"supplier":""},{"serialNumber":17,"description":"Supply and replacement of complete 3KW Heater Assembly Set","unit":"Set","qtyPerCoach":4,"totalQuantity":2400,"percentage":0.15,"rateBeforeDiscount":1686.25,"discountAmount":3298.3893124999995,"discountPercentage":195.605,"rateAfterDiscount":1490.645,"totalOrderAmount":536632.2,"rate":1490.645,"supplier":""},{"serialNumber":18,"description":"Supply and Replacement of power harness cable.","unit":"Nos.","qtyPerCoach":2,"totalQuantity":1200,"percentage":0.15,"rateBeforeDiscount":9856.25,"discountAmount":112688.97031249998,"discountPercentage":1143.3249999999998,"rateAfterDiscount":8712.925,"totalOrderAmount":1568326.4999999998,"rate":8712.925,"supplier":""},{"serialNumber":19,"description":"Supply  and  replacement of  Halting couplers including  hood  and  base lever - 24 pin type","unit":"Nos.","qtyPerCoach":2,"totalQuantity":1200,"percentage":0.1,"rateBeforeDiscount":2600.17,"discountAmount":7842.625473523999,"discountPercentage":301.61972,"rateAfterDiscount":2298.55028,"totalOrderAmount":275826.03359999997,"rate":2298.55028,"supplier":""},{"serialNumber":20,"description":"Supply and Replacement of 37 pin Control cable plug with\\r\\nsocket.","unit":"Nos.","qtyPerCoach":2,"totalQuantity":1200,"percentage":0.1,"rateBeforeDiscount":7632.49,"discountAmount":67575.68817611599,"discountPercentage":885.3688399999999,"rateAfterDiscount":6747.12116,"totalOrderAmount":809654.5392,"rate":6747.12116,"supplier":""},{"serialNumber":21,"description":"Supply and replacement of Harting couplers including hood and base lever - 32 pin type","unit":"Nos.","qtyPerCoach":2,"totalQuantity":1200,"percentage":0.05,"rateBeforeDiscount":3841.49,"discountAmount":17118.172687315997,"discountPercentage":445.61283999999995,"rateAfterDiscount":3395.87716,"totalOrderAmount":203752.6296,"rate":3395.87716,"supplier":""},{"serialNumber":22,"description":"Replacement of Solid state Temperature Controller(Electronic Thermostat)","unit":"Nos.","qtyPerCoach":2,"totalQuantity":1200,"percentage":0.3,"rateBeforeDiscount":0,"discountAmount":0,"discountPercentage":0,"rateAfterDiscount":0,"totalOrderAmount":0,"rate":0,"supplier":""},{"serialNumber":23,"description":"Supply and replacement of defective/damaged over heat protection switch 15A, 250-300V, with fix setting at 65 DEGREE\\r\\nCelsius","unit":"Nos","qtyPerCoach":4,"totalQuantity":2400,"percentage":0.6,"rateBeforeDiscount":460,"discountAmount":245.456,"discountPercentage":53.36,"rateAfterDiscount":406.64,"totalOrderAmount":585561.6,"rate":406.64,"supplier":""},{"serialNumber":24,"description":"Supply and replacement of Low pressure control Cut- out/switch","unit":"Nos.","qtyPerCoach":4,"totalQuantity":2400,"percentage":0.4,"rateBeforeDiscount":822.29,"discountAmount":784.346579156,"discountPercentage":95.38564,"rateAfterDiscount":726.90436,"totalOrderAmount":697828.1856,"rate":726.90436,"supplier":""},{"serialNumber":25,"description":"Supply and replacement of High pressure control cut- out/switch","unit":"Nos.","qtyPerCoach":4,"totalQuantity":2400,"percentage":0.5,"rateBeforeDiscount":1120,"discountAmount":1455.104,"discountPercentage":129.92,"rateAfterDiscount":990.08,"totalOrderAmount":1188096,"rate":990.08,"supplier":""},{"serialNumber":26,"description":"Supply of  Electronic Time Delay Relay","unit":"Nos","qtyPerCoach":2,"totalQuantity":1200,"percentage":0.3,"rateBeforeDiscount":2761.2,"discountAmount":8844.1015104,"discountPercentage":320.2992,"rateAfterDiscount":2440.9008,"totalOrderAmount":878724.288,"rate":2440.9008,"supplier":""},{"serialNumber":27,"description":"Supply of  PCB Board for AC Control Panel","unit":"Nos","qtyPerCoach":2,"totalQuantity":1200,"percentage":0.5,"rateBeforeDiscount":592.62,"discountAmount":407.390218704,"discountPercentage":68.74392,"rateAfterDiscount":523.87608,"totalOrderAmount":314325.648,"rate":523.87608,"supplier":""},{"serialNumber":28,"description":"Supply of 16 Amp Rotary switches for RSW 2 .","unit":"Nos","qtyPerCoach":1,"totalQuantity":600,"percentage":0.3,"rateBeforeDiscount":314.22,"discountAmount":114.53168174400001,"discountPercentage":36.44952,"rateAfterDiscount":277.77048,"totalOrderAmount":49998.686400000006,"rate":277.77048,"supplier":""},{"serialNumber":29,"description":"Supply of 16 Amp Rotary switches for RSW 3.","unit":"Nos","qtyPerCoach":1,"totalQuantity":600,"percentage":0.3,"rateBeforeDiscount":1050.86,"discountAmount":1280.9958179359999,"discountPercentage":121.89975999999999,"rateAfterDiscount":928.9602399999999,"totalOrderAmount":167212.84319999997,"rate":928.9602399999999,"supplier":""},{"serialNumber":30,"description":"Supply of 12 Amp Rotary switches for RSW 5.","unit":"Nos","qtyPerCoach":1,"totalQuantity":600,"percentage":0.05,"rateBeforeDiscount":357.18,"discountAmount":147.989960784,"discountPercentage":41.43288,"rateAfterDiscount":315.74712,"totalOrderAmount":9472.4136,"rate":315.74712,"supplier":""},{"serialNumber":31,"description":"Supply of MPCB for Compressor WITH AUXILIARY CONTACTS 1 NO + 1\\r\\nNC SIDE MOUNTING.","unit":"Nos.","qtyPerCoach":4,"totalQuantity":2400,"percentage":0.3,"rateBeforeDiscount":1989.08,"discountAmount":4589.469525823999,"discountPercentage":230.73327999999998,"rateAfterDiscount":1758.34672,"totalOrderAmount":1266009.6384,"rate":1758.34672,"supplier":""},{"serialNumber":32,"description":"Supply of MPCB for Condenser WITH AUXILIARY CONTACTS 1 NO + 1\\r\\nNC SIDE MOUNTING.","unit":"Nos.","qtyPerCoach":4,"totalQuantity":2400,"percentage":0.25,"rateBeforeDiscount":1013.79,"discountAmount":1192.2133903559998,"discountPercentage":117.59964,"rateAfterDiscount":896.1903599999999,"totalOrderAmount":537714.216,"rate":896.1903599999999,"supplier":""},{"serialNumber":33,"description":"Supply of MPCB for Blower  with 1NO + 1NC Auxillary Contact Block.","unit":"Nos.","qtyPerCoach":2,"totalQuantity":1200,"percentage":0.3,"rateBeforeDiscount":1496.27,"discountAmount":2597.035738964,"discountPercentage":173.56732,"rateAfterDiscount":1322.7026799999999,"totalOrderAmount":476172.96479999996,"rate":1322.7026799999999,"supplier":""},{"serialNumber":34,"description":"Supply of three pole 16 Amp MCB for Heater","unit":"Nos","qtyPerCoach":2,"totalQuantity":1200,"percentage":0.3,"rateBeforeDiscount":1813.74,"discountAmount":3815.9972336159994,"discountPercentage":210.39383999999998,"rateAfterDiscount":1603.34616,"totalOrderAmount":577204.6176,"rate":1603.34616,"supplier":""},{"serialNumber":35,"description":"Supply  of three pole 63 Amp MCB","unit":"Nos","qtyPerCoach":2,"totalQuantity":1200,"percentage":0.3,"rateBeforeDiscount":2155.81,"discountAmount":5391.119437075999,"discountPercentage":250.07395999999997,"rateAfterDiscount":1905.73604,"totalOrderAmount":686064.9744,"rate":1905.73604,"supplier":""},{"serialNumber":36,"description":"Supply of two pole 4 Amp/2Amp MCB.","unit":"Nos","qtyPerCoach":2,"totalQuantity":1200,"percentage":0.3,"rateBeforeDiscount":1276.78,"discountAmount":1890.9939153439998,"discountPercentage":148.10647999999998,"rateAfterDiscount":1128.67352,"totalOrderAmount":406322.4672,"rate":1128.67352,"supplier":""},{"serialNumber":37,"description":"Flushing the system with Nitrogen Gas and CTC cleaning.","unit":"Nos","qtyPerCoach":2,"totalQuantity":1200,"percentage":0.15,"rateBeforeDiscount":496.99,"discountAmount":286.518909716,"discountPercentage":57.650839999999995,"rateAfterDiscount":439.33916,"totalOrderAmount":79081.0488,"rate":439.33916,"supplier":""},{"serialNumber":38,"description":"Supply  of three pole 63 Amp Rotary Switches.","unit":"Nos.","qtyPerCoach":2,"totalQuantity":1200,"percentage":0.35,"rateBeforeDiscount":1080.88,"discountAmount":1355.2298263040002,"discountPercentage":125.38208,"rateAfterDiscount":955.4979200000001,"totalOrderAmount":401309.12640000007,"rate":955.4979200000001,"supplier":""},{"serialNumber":39,"description":"Supply of blower motor runner.","unit":"Set","qtyPerCoach":2,"totalQuantity":1200,"percentage":0.25,"rateBeforeDiscount":11955.76,"discountAmount":165810.628726016,"discountPercentage":1386.86816,"rateAfterDiscount":10568.89184,"totalOrderAmount":3170667.552,"rate":10568.89184,"supplier":""}]	cmfkzc1o50001i804mtuty789	\N	\N	\N	cmeve8gys0000s46d6wank1vs	2025-09-15 10:26:58.831	2025-09-15 10:26:59.007	\N	REGULAR	f	\N	\N	f	\N	\N	\N	\N	\N	\N
cmfl2c9fz000gjp04z4a03ifp	calibration certificate.pdf	Calibration Certificate/Statement	projects/pg/dtl/2024-22/op/17/lots/lot-001/departments/calibration/documents/calibration_certificate/statement/2025-09-19T07-56-28-334Z_calibration_certificate.pdf	2505273	application/pdf	RECEIVED	2025-09-19 07:56:28.456	\N	\N	{"receivedViaEmail":true,"senderEmail":"Ayush Som <ayush.web03@gmail.com>","emailSubject":"Re: Document Request - Comprehensive Maintenance Contract of RMPU of ICF AC coaches at Matunga Workshop, Qty-600 coaches for period of 02 years - LOT-001 - Calibration Documents","processedAt":"2025-09-19T07:56:28.456Z","textExtractionSkipped":true,"textExtractionNote":"Text extraction disabled for email attachments to improve performance and reduce AWS costs","s3Upload":{"success":true,"s3Key":"projects/pg/dtl/2024-22/op/17/lots/lot-001/departments/calibration/documents/calibration_certificate/statement/2025-09-19T07-56-28-334Z_calibration_certificate.pdf","uploadedAt":"2025-09-19T07:56:28.456Z","organizationPath":"PG/DTL/2024-22/OP/17/LOT-001/Calibration"},"documentMatch":{"originalRequirement":"Calibration Certificate/Statement","matchedAttachment":"calibration certificate.pdf","matchStrategy":"smart_email_matcher"}}	cmfkzc1o50001i804mtuty789	cmfl2c9dx0001jp04u9tl1048	cmfkrnh3l0000jw047ueklotq	\N	cmeve8gys0000s46d6wank1vs	2025-09-15 11:51:06.191	2025-09-19 07:56:28.457	\N	REGULAR	f	\N	\N	f	\N	\N	\N	\N	\N	\N
cmfl2c9fz000hjp04x40gu3y1	vendors_certificate_placeholder	Vendors certificate		0	application/pending	PENDING	\N	\N	\N	\N	cmfkzc1o50001i804mtuty789	cmfl2c9dx0001jp04u9tl1048	cmfkrl3gr0000jw04bynvvfjs	\N	cmeve8gys0000s46d6wank1vs	2025-09-15 11:51:06.191	2025-09-15 11:51:43.888	\N	REGULAR	f	\N	\N	f	\N	\N	\N	\N	\N	\N
cmfl2c9g4000ijp04ht70m41d	amendment_documents_custom_placeholder	Amendment Documents		0	application/pending	PENDING	\N	\N	\N	\N	cmfkzc1o50001i804mtuty789	cmfl2c9dx0001jp04u9tl1048	cmfkrl3gr0000jw04bynvvfjs	\N	cmeve8gys0000s46d6wank1vs	2025-09-15 11:51:06.196	2025-09-15 11:51:43.888	\N	REGULAR	f	\N	\N	f	\N	\N	\N	\N	\N	\N
cmfl2d8ai0003l2044iu2w2iw	offer_letter_lot_001.pdf	OFFER_LETTER_LOT-001.pdf	projects/PG/DTL/2024-22/OP/17/lots/LOT-001/generated/offer_letter_LOT-001.pdf	24497	application/pdf	PROCESSED	\N	2025-09-15 11:51:51.353	{"date":"15-09-2025","inspectionAgencyName":"RITES Limited","inspectionAgencyAddress":"Northern Region,\\n12th Floor, Core-2, Scope Minar\\nLaxmi Nagar, Delhi-110092","inspectionAgencyEmail":"rites@rites.com","projectTitle":"Comprehensive Maintenance Contract of RMPU of ICF  AC coaches at Matunga Workshop,  Qty-600 coaches for period of 02 years","lotNumber":"LOT-001","inspectionCaseNumber":"LOT-001","callDate":"15-09-2025","poNumber":"PG/DTL/2024-22/OP/17","poDate":"15-09-2025","items":[{"serialNumber":"1","description":"Supply and Replacement of anti- vibration mounting (AVM) pads of RMPU unit.","unit":"Nos.","quantity":600,"make":"Resistoflex"},{"serialNumber":"2","description":"Supply and Replacement of fresh and Return air filter(1 set consist of 4 fresh Air Filter and 4 nos. Return Air Filter.)","unit":"Set","quantity":50,"make":"usha"},{"serialNumber":"3","description":"Supply & fixing of set of new fresh air and return air duct removing the old ducts (1 Coach set - 2 nos. consist of supply air duct and 4 Nos. of return air\\r\\nduct), Note: 1 set consists of 5 meter Canvas cloth","unit":"Set","quantity":60,"make":"Delkon"},{"serialNumber":"24","description":"Supply and replacement of Low pressure control Cut- out/switch","unit":"Nos.","quantity":100,"make":"Danfoss"},{"serialNumber":"25","description":"Supply and replacement of High pressure control cut- out/switch","unit":"Nos.","quantity":100,"make":"Danfoss"},{"serialNumber":"26","description":"Supply of  Electronic Time Delay Relay","unit":"Nos","quantity":40,"make":"MAX MICRO SYSTEMS"},{"serialNumber":"31","description":"Supply of MPCB for Compressor WITH AUXILIARY CONTACTS 1 NO + 1\\r\\nNC SIDE MOUNTING.","unit":"Nos.","quantity":20,"make":"BCH"},{"serialNumber":"32","description":"Supply of MPCB for Condenser WITH AUXILIARY CONTACTS 1 NO + 1\\r\\nNC SIDE MOUNTING.","unit":"Nos.","quantity":20,"make":"BCH"},{"serialNumber":"39","description":"Supply of blower motor runner.","unit":"Set","quantity":60,"make":"Blowtech"}],"notes":""}	\N	cmfkzc1o50001i804mtuty789	cmfl2c9dx0001jp04u9tl1048	\N	\N	cmeve8gys0000s46d6wank1vs	2025-09-15 11:51:51.355	2025-09-15 11:51:51.355	\N	REGULAR	f	\N	\N	f	\N	\N	\N	\N	\N	\N
cmfl2c9fz000fjp045sxcmeno	InternalTest Record.pdf	Internal Test Records	projects/pg/dtl/2024-22/op/17/lots/lot-001/departments/amc/documents/internal_test_records/2025-09-19T07-56-24-310Z_internaltest_record.pdf	227975	application/pdf	RECEIVED	2025-09-19 07:56:24.446	\N	\N	{"receivedViaEmail":true,"senderEmail":"Ryzen _1 <ryzensingh@gmail.com>","emailSubject":"Re: Document Request - Comprehensive Maintenance Contract of RMPU of ICF AC coaches at Matunga Workshop, Qty-600 coaches for period of 02 years - LOT-001 - AMC Documents","processedAt":"2025-09-19T07:56:24.446Z","textExtractionSkipped":true,"textExtractionNote":"Text extraction disabled for email attachments to improve performance and reduce AWS costs","s3Upload":{"success":true,"s3Key":"projects/pg/dtl/2024-22/op/17/lots/lot-001/departments/amc/documents/internal_test_records/2025-09-19T07-56-24-310Z_internaltest_record.pdf","uploadedAt":"2025-09-19T07:56:24.446Z","organizationPath":"PG/DTL/2024-22/OP/17/LOT-001/AMC"},"documentMatch":{"originalRequirement":"Internal Test Records","matchedAttachment":"InternalTest Record.pdf","matchStrategy":"smart_email_matcher"}}	cmfkzc1o50001i804mtuty789	cmfl2c9dx0001jp04u9tl1048	cmfkrl3gr0000jw04bynvvfjs	\N	cmeve8gys0000s46d6wank1vs	2025-09-15 11:51:06.191	2025-09-19 07:56:24.447	\N	REGULAR	f	\N	\N	f	\N	\N	\N	\N	\N	\N
cmfl2c9fy000ejp04x8egeo3o	checksheet and inspection data.pdf	Checksheet & Inspection Data	projects/pg/dtl/2024-22/op/17/lots/lot-001/departments/amc/documents/checksheet_inspection_data/2025-09-19T07-56-24-553Z_checksheet_and_inspection_data.pdf	1274781	application/pdf	RECEIVED	2025-09-19 07:56:24.711	\N	\N	{"receivedViaEmail":true,"senderEmail":"Ryzen _1 <ryzensingh@gmail.com>","emailSubject":"Re: Document Request - Comprehensive Maintenance Contract of RMPU of ICF AC coaches at Matunga Workshop, Qty-600 coaches for period of 02 years - LOT-001 - AMC Documents","processedAt":"2025-09-19T07:56:24.711Z","textExtractionSkipped":true,"textExtractionNote":"Text extraction disabled for email attachments to improve performance and reduce AWS costs","s3Upload":{"success":true,"s3Key":"projects/pg/dtl/2024-22/op/17/lots/lot-001/departments/amc/documents/checksheet_inspection_data/2025-09-19T07-56-24-553Z_checksheet_and_inspection_data.pdf","uploadedAt":"2025-09-19T07:56:24.711Z","organizationPath":"PG/DTL/2024-22/OP/17/LOT-001/AMC"},"documentMatch":{"originalRequirement":"Checksheet & Inspection Data","matchedAttachment":"checksheet and inspection data.pdf","matchStrategy":"smart_email_matcher"}}	cmfkzc1o50001i804mtuty789	cmfl2c9dx0001jp04u9tl1048	cmfkrl3gr0000jw04bynvvfjs	\N	cmeve8gys0000s46d6wank1vs	2025-09-15 11:51:06.191	2025-09-19 07:56:24.712	\N	REGULAR	f	\N	\N	f	\N	\N	\N	\N	\N	\N
cmfl2d8bk0005l204cpqkllr6	packing_list_lot_001.pdf	PACKING_LIST_LOT-001.pdf	projects/PG/DTL/2024-22/OP/17/lots/LOT-001/generated/packing_list_LOT-001.pdf	26989	application/pdf	PROCESSED	\N	2025-09-15 11:51:51.391	{"date":"15-09-2025","poNumber":"PG/DTL/2024-22/OP/17","poDate":"15-09-2025","lotNumber":"LOT-001","items":[{"serialNumber":"1","description":"Supply and Replacement of anti- vibration mounting (AVM) pads of RMPU unit.","unit":"Nos.","quantity":600,"make":"Resistoflex","unitDimensions":null,"packingInfo":"600\\nTotal 12 box\\n(50x12=600)"},{"serialNumber":"2","description":"Supply and Replacement of fresh and Return air filter(1 set consist of 4 fresh Air Filter and 4 nos. Return Air Filter.)","unit":"Set","quantity":50,"make":"usha","unitDimensions":null,"packingInfo":"50\\nFresh Air Filter – 9 box (24x8+8=200)\\nReturn Air Filters – 5 box (10x5=50)\\nReturn Air Filter – 10 box (10x10=100)"},{"serialNumber":"3","description":"Supply & fixing of set of new fresh air and return air duct removing the old ducts (1 Coach set - 2 nos. consist of supply air duct and 4 Nos. of return air\\r\\nduct), Note: 1 set consists of 5 meter Canvas cloth","unit":"Set","quantity":60,"make":"Delkon","unitDimensions":null,"packingInfo":"60\\nTotal 2 box\\n(50x1+10=60)"},{"serialNumber":"24","description":"Supply and replacement of Low pressure control Cut- out/switch","unit":"Nos.","quantity":100,"make":"Danfoss","unitDimensions":null,"packingInfo":"100\\nTotal 2 box\\n(50x2=100)"},{"serialNumber":"25","description":"Supply and replacement of High pressure control cut- out/switch","unit":"Nos.","quantity":100,"make":"Danfoss","unitDimensions":null,"packingInfo":"100\\nTotal 2 box\\n(50x2=100)"},{"serialNumber":"26","description":"Supply of  Electronic Time Delay Relay","unit":"Nos","quantity":40,"make":"MAX MICRO SYSTEMS","unitDimensions":null,"packingInfo":"40\\nTotal 1 box\\n(50x0+40=40)"},{"serialNumber":"31","description":"Supply of MPCB for Compressor WITH AUXILIARY CONTACTS 1 NO + 1\\r\\nNC SIDE MOUNTING.","unit":"Nos.","quantity":20,"make":"BCH","unitDimensions":null,"packingInfo":"20\\nTotal 1 box\\n(50x0+20=20)"},{"serialNumber":"32","description":"Supply of MPCB for Condenser WITH AUXILIARY CONTACTS 1 NO + 1\\r\\nNC SIDE MOUNTING.","unit":"Nos.","quantity":20,"make":"BCH","unitDimensions":null,"packingInfo":"20\\nTotal 1 box\\n(50x0+20=20)"},{"serialNumber":"39","description":"Supply of blower motor runner.","unit":"Set","quantity":60,"make":"Blowtech","unitDimensions":null,"packingInfo":"60\\nTotal 2 box\\n(50x1+10=60)"}],"consigneeName":"Matunga","consigneeAddress":"Client Address","packingDetails":"Items packed according to specifications","totalBoxes":24,"detailedItems":[{"serialNumber":"1","description":"Supply and Replacement of anti- vibration mounting (AVM) pads of RMPU unit.","unit":"Nos.","quantity":600,"make":"Resistoflex","unitDimensions":null,"packingInfo":"600\\nTotal 12 box\\n(50x12=600)"},{"serialNumber":"2","description":"Supply and Replacement of fresh and Return air filter(1 set consist of 4 fresh Air Filter and 4 nos. Return Air Filter.)","unit":"Set","quantity":50,"make":"usha","unitDimensions":null,"packingInfo":"50\\nFresh Air Filter – 9 box (24x8+8=200)\\nReturn Air Filters – 5 box (10x5=50)\\nReturn Air Filter – 10 box (10x10=100)"},{"serialNumber":"3","description":"Supply & fixing of set of new fresh air and return air duct removing the old ducts (1 Coach set - 2 nos. consist of supply air duct and 4 Nos. of return air\\r\\nduct), Note: 1 set consists of 5 meter Canvas cloth","unit":"Set","quantity":60,"make":"Delkon","unitDimensions":null,"packingInfo":"60\\nTotal 2 box\\n(50x1+10=60)"},{"serialNumber":"24","description":"Supply and replacement of Low pressure control Cut- out/switch","unit":"Nos.","quantity":100,"make":"Danfoss","unitDimensions":null,"packingInfo":"100\\nTotal 2 box\\n(50x2=100)"},{"serialNumber":"25","description":"Supply and replacement of High pressure control cut- out/switch","unit":"Nos.","quantity":100,"make":"Danfoss","unitDimensions":null,"packingInfo":"100\\nTotal 2 box\\n(50x2=100)"},{"serialNumber":"26","description":"Supply of  Electronic Time Delay Relay","unit":"Nos","quantity":40,"make":"MAX MICRO SYSTEMS","unitDimensions":null,"packingInfo":"40\\nTotal 1 box\\n(50x0+40=40)"},{"serialNumber":"31","description":"Supply of MPCB for Compressor WITH AUXILIARY CONTACTS 1 NO + 1\\r\\nNC SIDE MOUNTING.","unit":"Nos.","quantity":20,"make":"BCH","unitDimensions":null,"packingInfo":"20\\nTotal 1 box\\n(50x0+20=20)"},{"serialNumber":"32","description":"Supply of MPCB for Condenser WITH AUXILIARY CONTACTS 1 NO + 1\\r\\nNC SIDE MOUNTING.","unit":"Nos.","quantity":20,"make":"BCH","unitDimensions":null,"packingInfo":"20\\nTotal 1 box\\n(50x0+20=20)"},{"serialNumber":"39","description":"Supply of blower motor runner.","unit":"Set","quantity":60,"make":"Blowtech","unitDimensions":null,"packingInfo":"60\\nTotal 2 box\\n(50x1+10=60)"}],"specialInstructions":""}	\N	cmfkzc1o50001i804mtuty789	cmfl2c9dx0001jp04u9tl1048	\N	\N	cmeve8gys0000s46d6wank1vs	2025-09-15 11:51:51.393	2025-09-15 11:51:51.393	\N	REGULAR	f	\N	\N	f	\N	\N	\N	\N	\N	\N
cmfl2d8cl0007l204jsh747bq	warranty_certificate_lot_001.pdf	WARRANTY_CERTIFICATE_LOT-001.pdf	projects/PG/DTL/2024-22/OP/17/lots/LOT-001/generated/warranty_certificate_LOT-001.pdf	23278	application/pdf	PROCESSED	\N	2025-09-15 11:51:51.429	{"date":"15-09-2025","contractDescription":"List of spares parts for RITES Inspection for POH of RMPU's of ICF AC Coaches vide","loaNumber":"PG/DTL/2024-22/OP/17","loaDate":"15-09-2025","supplierName":"M/S Prag Polymers Only","items":[{"serialNumber":"1","description":"Supply and Replacement of anti- vibration mounting (AVM) pads of RMPU unit.","unit":"Nos.","quantity":600,"make":"Resistoflex"},{"serialNumber":"2","description":"Supply and Replacement of fresh and Return air filter(1 set consist of 4 fresh Air Filter and 4 nos. Return Air Filter.)","unit":"Set","quantity":50,"make":"usha"},{"serialNumber":"3","description":"Supply & fixing of set of new fresh air and return air duct removing the old ducts (1 Coach set - 2 nos. consist of supply air duct and 4 Nos. of return air\\r\\nduct), Note: 1 set consists of 5 meter Canvas cloth","unit":"Set","quantity":60,"make":"Delkon"},{"serialNumber":"24","description":"Supply and replacement of Low pressure control Cut- out/switch","unit":"Nos.","quantity":100,"make":"Danfoss"},{"serialNumber":"25","description":"Supply and replacement of High pressure control cut- out/switch","unit":"Nos.","quantity":100,"make":"Danfoss"},{"serialNumber":"26","description":"Supply of  Electronic Time Delay Relay","unit":"Nos","quantity":40,"make":"MAX MICRO SYSTEMS"},{"serialNumber":"31","description":"Supply of MPCB for Compressor WITH AUXILIARY CONTACTS 1 NO + 1\\r\\nNC SIDE MOUNTING.","unit":"Nos.","quantity":20,"make":"BCH"},{"serialNumber":"32","description":"Supply of MPCB for Condenser WITH AUXILIARY CONTACTS 1 NO + 1\\r\\nNC SIDE MOUNTING.","unit":"Nos.","quantity":20,"make":"BCH"},{"serialNumber":"39","description":"Supply of blower motor runner.","unit":"Set","quantity":60,"make":"Blowtech"}]}	\N	cmfkzc1o50001i804mtuty789	cmfl2c9dx0001jp04u9tl1048	\N	\N	cmeve8gys0000s46d6wank1vs	2025-09-15 11:51:51.43	2025-09-15 11:51:51.43	\N	REGULAR	f	\N	\N	f	\N	\N	\N	\N	\N	\N
cmfl2d8dj0009l204g6dq2rny	internal_test_report_lot_001.pdf	INTERNAL_TEST_REPORT_LOT-001.pdf	projects/PG/DTL/2024-22/OP/17/lots/LOT-001/generated/internal_test_report_LOT-001.pdf	24550	application/pdf	PROCESSED	\N	2025-09-15 11:51:51.462	{"date":"25/04/2025","itemDescription":"LOA for the work 'Comprehensive Maintenance Contract of RMPU of ICF Coaches at Mumbai Workshop'","loaNumber":"CE-Shop-MTN-Electrical-PG-DTL-2024-25-OP-17/00617230125201","loaDate":"25/03/2025","maNumber":"NIL","quantityDescription":"List of spare parts for RITES Inspection for POH of RMPU's of ICF AC","quantityDetails":"Letter ref.# PG/DTL/2024-25/OP/17","alreadyInspected":"0","consigneeName":"Dy. CEE/G, Electrical Branch, Carriage Workshop, Matunga, Mumbai","consigneeAddress":"400019, Maharashtra, India","items":[{"serialNumber":"1","description":"Supply and Replacement of anti- vibration mounting (AVM) pads of RMPU unit.","unit":"Nos.","quantity":600,"make":"Resistoflex"},{"serialNumber":"2","description":"Supply and Replacement of fresh and Return air filter(1 set consist of 4 fresh Air Filter and 4 nos. Return Air Filter.)","unit":"Set","quantity":50,"make":"usha"},{"serialNumber":"3","description":"Supply & fixing of set of new fresh air and return air duct removing the old ducts (1 Coach set - 2 nos. consist of supply air duct and 4 Nos. of return air\\r\\nduct), Note: 1 set consists of 5 meter Canvas cloth","unit":"Set","quantity":60,"make":"Delkon"},{"serialNumber":"24","description":"Supply and replacement of Low pressure control Cut- out/switch","unit":"Nos.","quantity":100,"make":"Danfoss"},{"serialNumber":"25","description":"Supply and replacement of High pressure control cut- out/switch","unit":"Nos.","quantity":100,"make":"Danfoss"},{"serialNumber":"26","description":"Supply of  Electronic Time Delay Relay","unit":"Nos","quantity":40,"make":"MAX MICRO SYSTEMS"},{"serialNumber":"31","description":"Supply of MPCB for Compressor WITH AUXILIARY CONTACTS 1 NO + 1\\r\\nNC SIDE MOUNTING.","unit":"Nos.","quantity":20,"make":"BCH"},{"serialNumber":"32","description":"Supply of MPCB for Condenser WITH AUXILIARY CONTACTS 1 NO + 1\\r\\nNC SIDE MOUNTING.","unit":"Nos.","quantity":20,"make":"BCH"},{"serialNumber":"39","description":"Supply of blower motor runner.","unit":"Set","quantity":60,"make":"Blowtech"}]}	\N	cmfkzc1o50001i804mtuty789	cmfl2c9dx0001jp04u9tl1048	\N	\N	cmeve8gys0000s46d6wank1vs	2025-09-15 11:51:51.463	2025-09-15 11:52:54.239	\N	REGULAR	f	\N	\N	f	\N	\N	\N	\N	\N	\N
cmfl2c9fy000bjp04eavexwb3	call letter.pdf	Call Letter	projects/pg/dtl/2024-22/op/17/lots/lot-001/departments/amc/documents/call_letter/2025-09-19T07-56-24-761Z_call_letter.pdf	1541035	application/pdf	RECEIVED	2025-09-19 07:56:24.88	\N	\N	{"receivedViaEmail":true,"senderEmail":"Ryzen _1 <ryzensingh@gmail.com>","emailSubject":"Re: Document Request - Comprehensive Maintenance Contract of RMPU of ICF AC coaches at Matunga Workshop, Qty-600 coaches for period of 02 years - LOT-001 - AMC Documents","processedAt":"2025-09-19T07:56:24.880Z","textExtractionSkipped":true,"textExtractionNote":"Text extraction disabled for email attachments to improve performance and reduce AWS costs","s3Upload":{"success":true,"s3Key":"projects/pg/dtl/2024-22/op/17/lots/lot-001/departments/amc/documents/call_letter/2025-09-19T07-56-24-761Z_call_letter.pdf","uploadedAt":"2025-09-19T07:56:24.880Z","organizationPath":"PG/DTL/2024-22/OP/17/LOT-001/AMC"},"documentMatch":{"originalRequirement":"Call Letter","matchedAttachment":"call letter.pdf","matchStrategy":"smart_email_matcher"}}	cmfkzc1o50001i804mtuty789	cmfl2c9dx0001jp04u9tl1048	cmfkrl3gr0000jw04bynvvfjs	\N	cmeve8gys0000s46d6wank1vs	2025-09-15 11:51:06.191	2025-09-19 07:56:24.881	\N	REGULAR	f	\N	\N	f	\N	\N	\N	\N	\N	\N
cmfl2c9fy000djp04aogc3x3h	 Drawing Specification.pdf	Drawing/Specifications	projects/pg/dtl/2024-22/op/17/lots/lot-001/departments/amc/documents/drawing/specifications/2025-09-19T07-56-24-950Z_drawing_specification.pdf	1591363	application/pdf	RECEIVED	2025-09-19 07:56:25.068	\N	\N	{"receivedViaEmail":true,"senderEmail":"Ryzen _1 <ryzensingh@gmail.com>","emailSubject":"Re: Document Request - Comprehensive Maintenance Contract of RMPU of ICF AC coaches at Matunga Workshop, Qty-600 coaches for period of 02 years - LOT-001 - AMC Documents","processedAt":"2025-09-19T07:56:25.068Z","textExtractionSkipped":true,"textExtractionNote":"Text extraction disabled for email attachments to improve performance and reduce AWS costs","s3Upload":{"success":true,"s3Key":"projects/pg/dtl/2024-22/op/17/lots/lot-001/departments/amc/documents/drawing/specifications/2025-09-19T07-56-24-950Z_drawing_specification.pdf","uploadedAt":"2025-09-19T07:56:25.068Z","organizationPath":"PG/DTL/2024-22/OP/17/LOT-001/AMC"},"documentMatch":{"originalRequirement":"Drawing/Specifications","matchedAttachment":" Drawing Specification.pdf","matchStrategy":"smart_email_matcher"}}	cmfkzc1o50001i804mtuty789	cmfl2c9dx0001jp04u9tl1048	cmfkrl3gr0000jw04bynvvfjs	\N	cmeve8gys0000s46d6wank1vs	2025-09-15 11:51:06.191	2025-09-19 07:56:25.069	\N	REGULAR	f	\N	\N	f	\N	\N	\N	\N	\N	\N
cmfl2c9fy000cjp04s6zfb4kr	PO copy with amendments.pdf	PO Copy with Amendments	projects/pg/dtl/2024-22/op/17/lots/lot-001/departments/amc/documents/po_copy_with_amendments/2025-09-19T07-56-25-109Z_po_copy_with_amendments.pdf	2455876	application/pdf	RECEIVED	2025-09-19 07:56:25.219	\N	\N	{"receivedViaEmail":true,"senderEmail":"Ryzen _1 <ryzensingh@gmail.com>","emailSubject":"Re: Document Request - Comprehensive Maintenance Contract of RMPU of ICF AC coaches at Matunga Workshop, Qty-600 coaches for period of 02 years - LOT-001 - AMC Documents","processedAt":"2025-09-19T07:56:25.219Z","textExtractionSkipped":true,"textExtractionNote":"Text extraction disabled for email attachments to improve performance and reduce AWS costs","s3Upload":{"success":true,"s3Key":"projects/pg/dtl/2024-22/op/17/lots/lot-001/departments/amc/documents/po_copy_with_amendments/2025-09-19T07-56-25-109Z_po_copy_with_amendments.pdf","uploadedAt":"2025-09-19T07:56:25.219Z","organizationPath":"PG/DTL/2024-22/OP/17/LOT-001/AMC"},"documentMatch":{"originalRequirement":"PO Copy with Amendments","matchedAttachment":"PO copy with amendments.pdf","matchStrategy":"smart_email_matcher"}}	cmfkzc1o50001i804mtuty789	cmfl2c9dx0001jp04u9tl1048	cmfkrl3gr0000jw04bynvvfjs	\N	cmeve8gys0000s46d6wank1vs	2025-09-15 11:51:06.191	2025-09-19 07:56:25.22	\N	REGULAR	f	\N	\N	f	\N	\N	\N	\N	\N	\N
\.


--
-- Data for Name: email_logs; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.email_logs (id, "emailMessageId", "lotId", "projectId", "recipientEmail", "senderEmail", "emailType", status, subject, "sentAt", "processedAt", "userId", "createdAt", "newValues") FROM stdin;
cmfl2wbdl0001jp04io57uvyp	\N	cmfl2c9dx0001jp04u9tl1048	cmfkzc1o50001i804mtuty789	ryzensingh@gmail.com	\N	DOCUMENT_REMINDER	SENT	REMINDER: Documents Pending - PG/DTL/2024-22/OP/17 - LOT-001	2025-09-15 12:06:41.816	\N	cmeve8gys0000s46d6wank1vs	2025-09-15 12:06:41.817	{"department": "AMC", "daysPending": 1, "totalEmails": 1, "reminderType": "standard", "pendingDocuments": 7}
cmfl2wbk00003jp04dxpviyzm	\N	cmfl2c9dx0001jp04u9tl1048	cmfkzc1o50001i804mtuty789	ayush.web03@gmail.com	\N	DOCUMENT_REMINDER	SENT	REMINDER: Documents Pending - PG/DTL/2024-22/OP/17 - LOT-001	2025-09-15 12:06:42.047	\N	cmeve8gys0000s46d6wank1vs	2025-09-15 12:06:42.048	{"department": "Calibration", "daysPending": 1, "totalEmails": 1, "reminderType": "standard", "pendingDocuments": 1}
\.


--
-- Data for Name: extracted_document_requirements; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.extracted_document_requirements (id, "projectId", name, "createdAt", "updatedAt") FROM stdin;
cmfkzcet5001li804mfsqnbpc	cmfkzc1o50001i804mtuty789	Inspection Certificate	2025-09-15 10:27:14.298	2025-09-15 10:27:14.298
cmfkzcet5001mi804h8w1mu0u	cmfkzc1o50001i804mtuty789	Call Letter	2025-09-15 10:27:14.298	2025-09-15 10:27:14.298
cmfkzcet5001ni804jefjtnxr	cmfkzc1o50001i804mtuty789	PO Copy with Amendments	2025-09-15 10:27:14.298	2025-09-15 10:27:14.298
cmfkzcet5001oi804e54jce3e	cmfkzc1o50001i804mtuty789	Drawing/Specifications	2025-09-15 10:27:14.298	2025-09-15 10:27:14.298
cmfkzcet5001pi8048nc8emmr	cmfkzc1o50001i804mtuty789	Call Cancellation	2025-09-15 10:27:14.298	2025-09-15 10:27:14.298
cmfkzcet5001qi8041cp9xurl	cmfkzc1o50001i804mtuty789	Checksheet & Inspection Data	2025-09-15 10:27:14.298	2025-09-15 10:27:14.298
cmfkzcet5001ri804emg1k3ql	cmfkzc1o50001i804mtuty789	Lab Requisition	2025-09-15 10:27:14.298	2025-09-15 10:27:14.298
cmfkzcet5001si804if6oe50l	cmfkzc1o50001i804mtuty789	Lab Report	2025-09-15 10:27:14.298	2025-09-15 10:27:14.298
cmfkzcet5001ti804o3r7e6lf	cmfkzc1o50001i804mtuty789	Internal Test Records	2025-09-15 10:27:14.298	2025-09-15 10:27:14.298
cmfkzcet5001ui804qr81ugtw	cmfkzc1o50001i804mtuty789	Calibration Certificate/Statement	2025-09-15 10:27:14.298	2025-09-15 10:27:14.298
cmfkzcet5001vi804r9v2whch	cmfkzc1o50001i804mtuty789	Vendors certificate	2025-09-15 10:27:14.298	2025-09-15 10:27:14.298
cmfkzcet5001wi804jfalfd1i	cmfkzc1o50001i804mtuty789	Photo	2025-09-15 10:27:14.298	2025-09-15 10:27:14.298
\.


--
-- Data for Name: inspection_agencies; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.inspection_agencies (id, name, email, "isActive", "createdAt", "updatedAt") FROM stdin;
cmeve8l6t000as46ddrm24brm	RITES Limited	rites@rites.com	t	2025-08-28 12:42:09.606	2025-09-12 05:28:14.517
cmeve8lm9000bs46dveyfis0z	RDSO	rdso@indianrailways.gov.in	f	2025-08-28 12:42:10.162	2025-09-15 06:54:39.265
\.


--
-- Data for Name: invoice_items; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.invoice_items (id, "invoiceId", "masterItemId", "lotItemId", description, quantity, "unitPrice", "totalPrice", "taxRate", "taxAmount", "createdAt", "updatedAt") FROM stdin;
\.


--
-- Data for Name: invoices; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.invoices (id, "invoiceNumber", "projectId", "lotId", "supplierId", "totalAmount", "taxAmount", "discountAmount", "netAmount", currency, status, "invoiceDate", "dueDate", "paymentDate", "receivedDate", "documentId", "approvedById", "approvedAt", "rejectionReason", description, "vendorReference", "poReference", "createdAt", "updatedAt", "createdById") FROM stdin;
\.


--
-- Data for Name: item_suppliers; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.item_suppliers (id, "masterItemId", "supplierId", "createdAt", "updatedAt") FROM stdin;
cmfkzffuk0001lf0442lylv5k	cmfkzc2zv000ai804iyo62z89	cmf0k77vs0000l5043ozh6e44	2025-09-15 10:29:35.612	2025-09-15 10:29:35.612
cmfkzgbrm0001jr04c5vu27ow	cmfkzc2zv000bi804nveybj6u	cmf0k7e860003l504dtwq2suj	2025-09-15 10:30:16.979	2025-09-15 10:30:16.979
cmfkzitp40002l204tt1ewo7h	cmfkzc2zv000ci804ys0jru45	cmfkzitov0000l20497qxnr32	2025-09-15 10:32:13.528	2025-09-15 10:32:13.528
cmfkzj8gm0001jr04hemtp9yg	cmfkzc2zv000ci804ys0jru45	cmf0k7msi0006l50436vam2j0	2025-09-15 10:32:32.663	2025-09-15 10:32:32.663
cmfkzl43e0001jp04oaq21tli	cmfkzc2zv000di8047ku36to9	cmfkzkmrg0000l204m21z4i4t	2025-09-15 10:34:00.314	2025-09-15 10:34:00.314
cmfkznc4c0001jp04u0w1imjp	cmfkzc2zv000ei80442ivxwkc	cmfkzkmrg0000l204m21z4i4t	2025-09-15 10:35:44.029	2025-09-15 10:35:44.029
cmfkznsqp0003jp0483zduvs2	cmfkzc2zv000fi804f5rzyt44	cmfkzkmrg0000l204m21z4i4t	2025-09-15 10:36:05.569	2025-09-15 10:36:05.569
cmfkzq8bk0001jp04mqtblbxr	cmfkzc2zv000gi804jwaaxedy	cmfkzkmrg0000l204m21z4i4t	2025-09-15 10:37:59.072	2025-09-15 10:37:59.072
cmfkzqh3s0004jp04kzuy16dx	cmfkzc2zv000hi804l57ayohu	cmfkzqh3m0002jp04qiielyvf	2025-09-15 10:38:10.456	2025-09-15 10:38:10.456
cmfkzr9ih0002jr049cqgdr2s	cmfkzc2zv000ii804q3duo4ac	cmfkzr9ia0000jr04r6la3o08	2025-09-15 10:38:47.274	2025-09-15 10:38:47.274
cmfkzroy10004jr04a8lx0o04	cmfkzc2zv000ji80415meonsx	cmfkzr9ia0000jr04r6la3o08	2025-09-15 10:39:07.273	2025-09-15 10:39:07.273
cmfkztb290002jr04cjwky1j6	cmfkzc2zv000ki804ew8ud1c8	cmfkztb220000jr04y7z3xvka	2025-09-15 10:40:22.593	2025-09-15 10:40:22.593
cmfkzu0ym0001jr04fctd40k2	cmfkzc2zv000li804163ggic1	cmfkztb220000jr04y7z3xvka	2025-09-15 10:40:56.158	2025-09-15 10:40:56.158
cmfkzyl400001jp04h4ht0jwp	cmfkzc2zv000mi804c6a9kqk7	cmf0k849k0009l5040faci53j	2025-09-15 10:44:28.896	2025-09-15 10:44:28.896
cmfkzys910002jr04tg0af0da	cmfkzc2zv000ni804b8v7tk13	cmfkzys8t0000jr04zwbkqiji	2025-09-15 10:44:38.149	2025-09-15 10:44:38.149
cmfkzz3rf0001ih04f1burx5r	cmfkzc2zv000oi8041y8me757	cmf0k849k0009l5040faci53j	2025-09-15 10:44:53.067	2025-09-15 10:44:53.067
cmfkzzjcc0001jp04a9fjmojg	cmfkzc2zv000qi804p5i0zelr	cmf0k849k0009l5040faci53j	2025-09-15 10:45:13.26	2025-09-15 10:45:13.26
cmfl00bgl0002jp048llm6etv	cmfkzc2zv000ri804sgytvbc2	cmfl00bge0000jp04h4em708w	2025-09-15 10:45:49.701	2025-09-15 10:45:49.701
cmfl00of60005jp04nroi5omr	cmfkzc2zv000si8044b825aea	cmfl00oew0003jp04ie7vni0r	2025-09-15 10:46:06.498	2025-09-15 10:46:06.498
cmfl011wt0007jp04ovuqoxis	cmfkzc2zv000ti804h25j8gwk	cmfl00bge0000jp04h4em708w	2025-09-15 10:46:23.981	2025-09-15 10:46:23.981
cmfl01ed20001ih04hcio7b4k	cmfkzc2zv000ui804sbze6nwj	cmfl00oew0003jp04ie7vni0r	2025-09-15 10:46:40.118	2025-09-15 10:46:40.118
cmfl020060005jr047ru9b6rb	cmfkzc2zv000vi804v5imw20u	cmfl01zzz0003jr04ri3f88j1	2025-09-15 10:47:08.167	2025-09-15 10:47:08.167
cmfl02bz40008jr040cw4eygh	cmfkzc2zv000wi804tsd18o57	cmfl02bz00006jr042lbgrkdi	2025-09-15 10:47:23.681	2025-09-15 10:47:23.681
cmfl02o2k000ajr04epmzmqyi	cmfkzc2zv000xi804kfd3tg41	cmf0k849k0009l5040faci53j	2025-09-15 10:47:39.356	2025-09-15 10:47:39.356
cmfl092xz0001jr04v0v5cxij	cmfkzc2zv000yi8042h1xu6wb	cmf0k849k0009l5040faci53j	2025-09-15 10:52:38.568	2025-09-15 10:52:38.568
cmfl09djd0001jp0480agqter	cmfkzc2zv000zi804dfinpzc0	cmfl00bge0000jp04h4em708w	2025-09-15 10:52:52.297	2025-09-15 10:52:52.297
cmfl09mji0004jp045n7bdcvl	cmfkzc2zv0010i804u442l40z	cmfl09mjc0002jp04aatytab0	2025-09-15 10:53:03.966	2025-09-15 10:53:03.966
cmfl0aedg0007jp0403d9cc9f	cmfkzc2zw0011i8044yio14i4	cmfl0aedb0005jp04orearo6t	2025-09-15 10:53:40.037	2025-09-15 10:53:40.037
cmfl0amlr0001jp04fy88z7p3	cmfkzc2zw0012i804l7zs1fgr	cmfl0aedb0005jp04orearo6t	2025-09-15 10:53:50.704	2025-09-15 10:53:50.704
cmfl0ayjt0003jp04xdiax3a6	cmfkzc2zw0013i804ucyjvnsp	cmfl0aedb0005jp04orearo6t	2025-09-15 10:54:06.186	2025-09-15 10:54:06.186
cmfl0c9zr0001jr04bnsljlvu	cmfkzc2zw0014i804fy3m9d9w	cmf0k8zyi000hl5043skr1076	2025-09-15 10:55:07.671	2025-09-15 10:55:07.671
cmfl0cf3s0003jr04iob1jgh2	cmfkzc2zw0015i804u34wz5to	cmf0k8zyi000hl5043skr1076	2025-09-15 10:55:14.297	2025-09-15 10:55:14.297
cmfl0cuxo0005jr0476nwcy1q	cmfkzc2zw0016i804c7zmxx6w	cmf0k8zyi000hl5043skr1076	2025-09-15 10:55:34.812	2025-09-15 10:55:34.812
cmfl0fk5j0002jr04au3nje6o	cmfkzc2zw0017i8044dwhz5pf	cmfl0fk5c0000jr04tvd4di6b	2025-09-15 10:57:40.808	2025-09-15 10:57:40.808
cmfl0glch0002jp04qd2zyrqb	cmfkzc2zw0017i8044dwhz5pf	cmfl0glc80000jp04exag7vqc	2025-09-15 10:58:29.01	2025-09-15 10:58:29.01
cmfl0gs720005jp04aa27lzve	cmfkzc2zw0017i8044dwhz5pf	cmfl0gs6x0003jp04ystia0qj	2025-09-15 10:58:37.887	2025-09-15 10:58:37.887
cmfl0hbnz0001jr04zidrftwe	cmfkzc2zw0018i8042o8g01mf	cmfl0fk5c0000jr04tvd4di6b	2025-09-15 10:59:03.119	2025-09-15 10:59:03.119
cmfl0hhhv0003jr040m9gyq3a	cmfkzc2zw0018i8042o8g01mf	cmfl0glc80000jp04exag7vqc	2025-09-15 10:59:10.676	2025-09-15 10:59:10.676
cmfl0hnji0005jr04en9kq6ek	cmfkzc2zw0018i8042o8g01mf	cmfl0gs6x0003jp04ystia0qj	2025-09-15 10:59:18.511	2025-09-15 10:59:18.511
cmfl0huoi0007jr04jaolcvt2	cmfkzc2zw0019i804t4o50tub	cmfl0fk5c0000jr04tvd4di6b	2025-09-15 10:59:27.763	2025-09-15 10:59:27.763
cmfl0i1o40009jr04k7t5bcl8	cmfkzc2zw0019i804t4o50tub	cmfl0glc80000jp04exag7vqc	2025-09-15 10:59:36.821	2025-09-15 10:59:36.821
cmfl0i70w000bjr04sn1e6u73	cmfkzc2zw0019i804t4o50tub	cmfl0gs6x0003jp04ystia0qj	2025-09-15 10:59:43.76	2025-09-15 10:59:43.76
cmfl0jx180001jp0420r9i7o0	cmfkzc2zw001bi804neu89dj7	cmfl0aedb0005jp04orearo6t	2025-09-15 11:01:04.125	2025-09-15 11:01:04.125
cmfl0k9nc0003jp04f0i0q1in	cmfkzc2zw001ci804akze6wla	cmf0k9j3q000ml504jbf7kev1	2025-09-15 11:01:20.472	2025-09-15 11:01:20.472
\.


--
-- Data for Name: lot_items; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.lot_items (id, "lotId", "masterItemId", quantity, "internalDetails", "isRevisionItem", "hasMixedQuantities", "revisionQuantity", "newQuantity", "approvedQuantity", "rejectedQuantity", "rejectionReason", "selectedSupplierId", "useCustomPacking", "customPackingDetails", "packingNotes", "createdAt", "updatedAt") FROM stdin;
cmfl2c9eu0002jp04mvtyjod8	cmfl2c9dx0001jp04u9tl1048	cmfkzc2zv000ai804iyo62z89	600		f	f	0	600	\N	\N	\N	cmf0k77vs0000l5043ozh6e44	f	null	\N	2025-09-15 11:51:06.15	2025-09-15 11:51:43.893
cmfl2c9eu0003jp04dn1s0pr4	cmfl2c9dx0001jp04u9tl1048	cmfkzc2zv000bi804nveybj6u	50		f	f	0	50	\N	\N	\N	cmf0k7e860003l504dtwq2suj	f	null	\N	2025-09-15 11:51:06.15	2025-09-15 11:51:43.897
cmfl2c9eu0004jp04ku90jppk	cmfl2c9dx0001jp04u9tl1048	cmfkzc2zv000ci804ys0jru45	60		f	f	0	60	\N	\N	\N	cmf0k7msi0006l50436vam2j0	f	null	\N	2025-09-15 11:51:06.15	2025-09-15 11:51:43.9
cmfl2c9eu0005jp04c6ycud3w	cmfl2c9dx0001jp04u9tl1048	cmfkzc2zv000xi804kfd3tg41	100		f	f	0	100	\N	\N	\N	cmf0k849k0009l5040faci53j	f	null	\N	2025-09-15 11:51:06.15	2025-09-15 11:51:43.903
cmfl2c9eu0006jp04weufwald	cmfl2c9dx0001jp04u9tl1048	cmfkzc2zv000yi8042h1xu6wb	100		f	f	0	100	\N	\N	\N	cmf0k849k0009l5040faci53j	f	null	\N	2025-09-15 11:51:06.15	2025-09-15 11:51:43.905
cmfl2c9eu0007jp04buqbuahd	cmfl2c9dx0001jp04u9tl1048	cmfkzc2zv000zi804dfinpzc0	40		f	f	0	40	\N	\N	\N	cmfl00bge0000jp04h4em708w	f	null	\N	2025-09-15 11:51:06.15	2025-09-15 11:51:43.908
cmfl2c9eu0008jp04lalf6i9t	cmfl2c9dx0001jp04u9tl1048	cmfkzc2zw0014i804fy3m9d9w	20		f	f	0	20	\N	\N	\N	cmf0k8zyi000hl5043skr1076	f	null	\N	2025-09-15 11:51:06.15	2025-09-15 11:51:43.91
cmfl2c9eu0009jp0422f4r90q	cmfl2c9dx0001jp04u9tl1048	cmfkzc2zw0015i804u34wz5to	20		f	f	0	20	\N	\N	\N	cmf0k8zyi000hl5043skr1076	f	null	\N	2025-09-15 11:51:06.15	2025-09-15 11:51:43.912
cmfl2c9eu000ajp04ow8rf0vc	cmfl2c9dx0001jp04u9tl1048	cmfkzc2zw001ci804akze6wla	60		f	f	0	60	\N	\N	\N	cmf0k9j3q000ml504jbf7kev1	f	null	\N	2025-09-15 11:51:06.15	2025-09-15 11:51:43.915
\.


--
-- Data for Name: lot_revisions; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.lot_revisions (id, "lotId", "originalLotId", "masterItemId", "itemDescription", "originalQuantity", "revisedQuantity", "quantityDiff", reason, status, "requestedById", "approvedById", "approvedAt", "createdAt", "updatedAt") FROM stdin;
\.


--
-- Data for Name: lots; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.lots (id, "lotNumber", "projectId", priority, "inspectionDate", notes, status, "hasRevisions", "totalValue", progress, "createdAt", "updatedAt", "createdById", "stakeholderName") FROM stdin;
cmfl2c9dx0001jp04u9tl1048	LOT-001	cmfkzc1o50001i804mtuty789	LOW	2025-09-15 00:00:00		DOCUMENTS_PENDING	f	1519063.832	29	2025-09-15 11:51:06.118	2025-09-19 07:56:24.47	cmeve8gys0000s46d6wank1vs	Sachin Kumar Singh
\.


--
-- Data for Name: master_items; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.master_items (id, "projectId", "serialNumber", description, unit, "totalQuantity", "remainingQuantity", rate, supplier, status, "lastLotRevisedQty", "createdAt", "updatedAt", "discountAmount", "discountPercentage", percentage, "qtyPerCoach", "rateAfterDiscount", "rateBeforeDiscount", "totalOrderAmount", "packingTemplate", "itemType", "hasSubItems") FROM stdin;
cmfkzc2zv000di8047ku36to9	cmfkzc1o50001i804mtuty789	4	Replacement of blower motor.	Nos.	1200	1200	0		NEVER_SENT	0	2025-09-15 10:26:58.986	2025-09-15 11:01:36.843	0	0	0.25	2	0	0	0	\N	SIMPLE	f
cmfkzc2zv000ei80442ivxwkc	cmfkzc1o50001i804mtuty789	5	Transportation,    repair, rewinding, Supply  and replacement  of  blower motor with runner	Nos.	1200	1200	2057.97852		NEVER_SENT	0	2025-09-15 10:26:58.986	2025-09-15 11:01:36.849	6286.879469844002	270.05148	0.75	2	2057.97852	2328.03	1852180.668	\N	SIMPLE	f
cmfkzc2zv000fi804f5rzyt44	cmfkzc1o50001i804mtuty789	6	Supply and Replacement of condenser motor .	Nos.	2400	2400	7510.464		NEVER_SENT	0	2025-09-15 10:26:58.986	2025-09-15 11:01:36.854	83731.13855999999	985.536	0.25	4	7510.464	8496	4506278.4	\N	SIMPLE	f
cmfkzc2zv000gi804jwaaxedy	cmfkzc1o50001i804mtuty789	7	Transportation,    repair, rewinding, Supply       and replacement       of\r\ncondenser motor with Fan Blade.	Nos.	2400	2400	1967.0768		NEVER_SENT	0	2025-09-15 10:26:58.986	2025-09-15 11:01:36.858	5743.757446399998	258.1231999999999	0.75	4	1967.0768	2225.2	3540738.24	\N	SIMPLE	f
cmfkzc2zv000hi804l57ayohu	cmfkzc1o50001i804mtuty789	8	Supply and Replacement of condensor Fan Blade with Aluminium Hub/fibre\r\nhub	Nos	2400	2400	2659.956		NEVER_SENT	0	2025-09-15 10:26:58.986	2025-09-15 11:01:36.863	10502.73396	349.044	0.5	4	2659.956	3009	3191947.2	\N	SIMPLE	f
cmfkzc2zv000ii804q3duo4ac	cmfkzc1o50001i804mtuty789	9	Supply and replacement of Evaporator coil (Left Hand or Right Hand as per field requirement)	Nos	2400	2400	136728.86344		NEVER_SENT	0	2025-09-15 10:26:58.986	2025-09-15 11:01:36.868	27750695.15520929	17941.79656	0.01	4	136728.86344	154670.66	1640746.36128	\N	SIMPLE	f
cmfkzc2zv000ji80415meonsx	cmfkzc1o50001i804mtuty789	10	Supply and replacement of condenser coil (Left Hand or Right Hand as per field requirement)	Nos	2400	2400	161954.83772		NEVER_SENT	0	2025-09-15 10:26:58.986	2025-09-15 11:01:36.872	38935101.36803272	21251.99228	0.01	4	161954.83772	183206.83	1943458.05264	\N	SIMPLE	f
cmfkzc2zv000ki804ew8ud1c8	cmfkzc1o50001i804mtuty789	11	Supply and Replacement of scroll compressor suitable for R407\r\nrefrigerant.	Nos.	2400	2400	40160.12		NEVER_SENT	0	2025-09-15 10:26:58.986	2025-09-15 11:01:36.879	2394106.484	5269.879999999999	0.05	4	40160.12	45430	4819214.4	\N	SIMPLE	f
cmfkzc2zv000li804163ggic1	cmfkzc1o50001i804mtuty789	12	Supply and Replacement of R407/R22 refrigerant in RMPU compressor	Kg	9600	9600	419.12208		NEVER_SENT	0	2025-09-15 10:26:58.986	2025-09-15 11:01:36.884	260.756138304	54.99791999999999	0.5	16	419.12208	474.12	2011785.984	\N	SIMPLE	f
cmfkzc2zv000mi804c6a9kqk7	cmfkzc1o50001i804mtuty789	13	Supply and Replacement of Thermostatic Expansion Valve	Nos	2400	2400	1781.64896		NEVER_SENT	0	2025-09-15 10:26:58.986	2025-09-15 11:01:36.889	4711.918136576	233.79104	0.05	4	1781.64896	2015.44	213797.8752	\N	SIMPLE	f
cmfkzc2zv000ni804b8v7tk13	cmfkzc1o50001i804mtuty789	14	Supply and replacement Of ACCUMULATOR.	Nos.	2400	2400	2165.92376		NEVER_SENT	0	2025-09-15 10:26:58.986	2025-09-15 11:01:36.895	6963.695782735998	284.21624	0.02	4	2165.92376	2450.14	103964.34048	\N	SIMPLE	f
cmfkzc2zv000oi8041y8me757	cmfkzc1o50001i804mtuty789	15	Supply and replacement Of\r\nsuitable Drier filter	Nos	2400	2400	356.74704		NEVER_SENT	0	2025-09-15 10:26:58.986	2025-09-15 11:01:36.899	188.918381376	46.81296	0.1	4	356.74704	403.56	85619.2896	\N	SIMPLE	f
cmfkzc2zv000pi804dohci2yn	cmfkzc1o50001i804mtuty789	16	Supply and replacement Of vane relay	Nos	2400	2400	228.44328		NEVER_SENT	0	2025-09-15 10:26:58.986	2025-09-15 11:01:36.904	77.465839824	29.97672	0.5	4	228.44328	258.42	274131.936	\N	SIMPLE	f
cmfkzc2zv000qi804p5i0zelr	cmfkzc1o50001i804mtuty789	17	Supply and replacement of complete 3KW Heater Assembly Set	Set	2400	2400	1490.645		NEVER_SENT	0	2025-09-15 10:26:58.986	2025-09-15 11:01:36.908	3298.3893125	195.605	0.15	4	1490.645	1686.25	536632.2	\N	SIMPLE	f
cmfkzc2zv000ri804sgytvbc2	cmfkzc1o50001i804mtuty789	18	Supply and Replacement of power harness cable.	Nos.	1200	1200	8712.925		NEVER_SENT	0	2025-09-15 10:26:58.986	2025-09-15 11:01:36.912	112688.9703125	1143.325	0.15	2	8712.925	9856.25	1568326.5	\N	SIMPLE	f
cmfkzc2zv000ai804iyo62z89	cmfkzc1o50001i804mtuty789	1	Supply and Replacement of anti- vibration mounting (AVM) pads of RMPU unit.	Nos.	7200	6600	761.4775999999999		PARTIALLY_SENT	0	2025-09-15 10:26:58.986	2025-09-15 11:51:06.159	860.7315535999999	99.9224	1	12	761.4775999999999	861.4	5482638.72	\N	SIMPLE	f
cmfkzc2zv000ci804ys0jru45	cmfkzc1o50001i804mtuty789	3	Supply & fixing of set of new fresh air and return air duct removing the old ducts (1 Coach set - 2 nos. consist of supply air duct and 4 Nos. of return air\r\nduct), Note: 1 set consists of 5 meter Canvas cloth	Set	600	540	1760.3092		PARTIALLY_SENT	0	2025-09-15 10:26:58.986	2025-09-15 11:51:06.166	4599.719800399999	230.9908	1	1	1760.3092	1991.3	1056185.52	\N	SIMPLE	f
cmfkzc2zv000bi804nveybj6u	cmfkzc1o50001i804mtuty789	2	Supply and Replacement of fresh and Return air filter(1 set consist of 4 fresh Air Filter and 4 nos. Return Air Filter.)	Sets	600	550	0		PARTIALLY_SENT	0	2025-09-15 10:26:58.986	2025-09-15 12:00:29.813	200803.71284	1526.212	1	1	11630.788	13157	6978472.800000001	{"subItems": [{"id": "sub_1757935309124", "dimensions": "", "description": "Fresh Air Filter", "quantityPerParent": 4, "defaultItemsPerBox": 24}, {"id": "sub_1757935857261", "dimensions": "", "description": "Return Air Filters", "quantityPerParent": 1, "defaultItemsPerBox": 10}, {"id": "sub_1757935905149", "dimensions": "", "description": "Return Air Filter", "quantityPerParent": 2, "defaultItemsPerBox": 10}]}	SIMPLE	f
cmfkzc2zv000si8044b825aea	cmfkzc1o50001i804mtuty789	19	Supply  and  replacement of  Halting couplers including  hood  and  base lever - 24 pin type	Nos.	1200	1200	2298.55028		NEVER_SENT	0	2025-09-15 10:26:58.986	2025-09-15 11:01:36.916	7842.625473523999	301.61972	0.1	2	2298.55028	2600.17	275826.0336	\N	SIMPLE	f
cmfkzc2zv000ti804h25j8gwk	cmfkzc1o50001i804mtuty789	20	Supply and Replacement of 37 pin Control cable plug with\r\nsocket.	Nos.	1200	1200	6747.12116		NEVER_SENT	0	2025-09-15 10:26:58.986	2025-09-15 11:01:36.921	67575.68817611599	885.3688399999999	0.1	2	6747.12116	7632.49	809654.5392	\N	SIMPLE	f
cmfkzc2zv000ui804sbze6nwj	cmfkzc1o50001i804mtuty789	21	Supply and replacement of Harting couplers including hood and base lever - 32 pin type	Nos.	1200	1200	3395.87716		NEVER_SENT	0	2025-09-15 10:26:58.986	2025-09-15 11:01:36.926	17118.172687316	445.6128399999999	0.05	2	3395.87716	3841.49	203752.6296	\N	SIMPLE	f
cmfkzc2zv000vi804v5imw20u	cmfkzc1o50001i804mtuty789	22	Replacement of Solid state Temperature Controller(Electronic Thermostat)	Nos.	1200	1200	0		NEVER_SENT	0	2025-09-15 10:26:58.986	2025-09-15 11:01:36.93	0	0	0.3	2	0	0	0	\N	SIMPLE	f
cmfkzc2zv000wi804tsd18o57	cmfkzc1o50001i804mtuty789	23	Supply and replacement of defective/damaged over heat protection switch 15A, 250-300V, with fix setting at 65 DEGREE\r\nCelsius	Nos	2400	2400	406.64		NEVER_SENT	0	2025-09-15 10:26:58.986	2025-09-15 11:01:36.934	245.456	53.36	0.6	4	406.64	460	585561.6	\N	SIMPLE	f
cmfkzc2zv0010i804u442l40z	cmfkzc1o50001i804mtuty789	27	Supply of  PCB Board for AC Control Panel	Nos	1200	1200	523.87608		NEVER_SENT	0	2025-09-15 10:26:58.986	2025-09-15 11:01:36.95	407.390218704	68.74392	0.5	2	523.87608	592.62	314325.648	\N	SIMPLE	f
cmfkzc2zw0011i8044yio14i4	cmfkzc1o50001i804mtuty789	28	Supply of 16 Amp Rotary switches for RSW 2 .	Nos	600	600	277.77048		NEVER_SENT	0	2025-09-15 10:26:58.986	2025-09-15 11:01:36.954	114.531681744	36.44952	0.3	1	277.77048	314.22	49998.68640000001	\N	SIMPLE	f
cmfkzc2zw0012i804l7zs1fgr	cmfkzc1o50001i804mtuty789	29	Supply of 16 Amp Rotary switches for RSW 3.	Nos	600	600	928.9602399999999		NEVER_SENT	0	2025-09-15 10:26:58.986	2025-09-15 11:01:36.959	1280.995817936	121.89976	0.3	1	928.9602399999999	1050.86	167212.8432	\N	SIMPLE	f
cmfkzc2zw0013i804ucyjvnsp	cmfkzc1o50001i804mtuty789	30	Supply of 12 Amp Rotary switches for RSW 5.	Nos	600	600	315.74712		NEVER_SENT	0	2025-09-15 10:26:58.986	2025-09-15 11:01:36.963	147.989960784	41.43288	0.05	1	315.74712	357.18	9472.4136	\N	SIMPLE	f
cmfkzc2zw0016i804c7zmxx6w	cmfkzc1o50001i804mtuty789	33	Supply of MPCB for Blower  with 1NO + 1NC Auxillary Contact Block.	Nos.	1200	1200	1322.70268		NEVER_SENT	0	2025-09-15 10:26:58.986	2025-09-15 11:01:36.975	2597.035738964	173.56732	0.3	2	1322.70268	1496.27	476172.9648	\N	SIMPLE	f
cmfkzc2zw0017i8044dwhz5pf	cmfkzc1o50001i804mtuty789	34	Supply of three pole 16 Amp MCB for Heater	Nos	1200	1200	1603.34616		NEVER_SENT	0	2025-09-15 10:26:58.986	2025-09-15 11:01:36.979	3815.997233615999	210.39384	0.3	2	1603.34616	1813.74	577204.6176	\N	SIMPLE	f
cmfkzc2zw0018i8042o8g01mf	cmfkzc1o50001i804mtuty789	35	Supply  of three pole 63 Amp MCB	Nos	1200	1200	1905.73604		NEVER_SENT	0	2025-09-15 10:26:58.986	2025-09-15 11:01:36.983	5391.119437075999	250.07396	0.3	2	1905.73604	2155.81	686064.9744	\N	SIMPLE	f
cmfkzc2zw0019i804t4o50tub	cmfkzc1o50001i804mtuty789	36	Supply of two pole 4 Amp/2Amp MCB.	Nos	1200	1200	1128.67352		NEVER_SENT	0	2025-09-15 10:26:58.986	2025-09-15 11:01:36.988	1890.993915344	148.10648	0.3	2	1128.67352	1276.78	406322.4672	\N	SIMPLE	f
cmfkzc2zw001ai804bfcxa3ks	cmfkzc1o50001i804mtuty789	37	Flushing the system with Nitrogen Gas and CTC cleaning.	Nos	1200	1200	439.33916		NEVER_SENT	0	2025-09-15 10:26:58.986	2025-09-15 11:01:36.992	286.518909716	57.65084	0.15	2	439.33916	496.99	79081.0488	\N	SIMPLE	f
cmfkzc2zw001bi804neu89dj7	cmfkzc1o50001i804mtuty789	38	Supply  of three pole 63 Amp Rotary Switches.	Nos.	1200	1200	955.4979200000001		NEVER_SENT	0	2025-09-15 10:26:58.986	2025-09-15 11:01:36.996	1355.229826304	125.38208	0.35	2	955.4979200000001	1080.88	401309.1264000001	\N	SIMPLE	f
cmfkzc2zv000xi804kfd3tg41	cmfkzc1o50001i804mtuty789	24	Supply and replacement of Low pressure control Cut- out/switch	Nos.	2400	2300	726.90436		PARTIALLY_SENT	0	2025-09-15 10:26:58.986	2025-09-15 11:51:06.169	784.346579156	95.38564	0.4	4	726.90436	822.29	697828.1856	\N	SIMPLE	f
cmfkzc2zv000yi8042h1xu6wb	cmfkzc1o50001i804mtuty789	25	Supply and replacement of High pressure control cut- out/switch	Nos.	2400	2300	990.08		PARTIALLY_SENT	0	2025-09-15 10:26:58.986	2025-09-15 11:51:06.172	1455.104	129.92	0.5	4	990.08	1120	1188096	\N	SIMPLE	f
cmfkzc2zv000zi804dfinpzc0	cmfkzc1o50001i804mtuty789	26	Supply of  Electronic Time Delay Relay	Nos	1200	1160	2440.9008		PARTIALLY_SENT	0	2025-09-15 10:26:58.986	2025-09-15 11:51:06.174	8844.1015104	320.2992	0.3	2	2440.9008	2761.2	878724.288	\N	SIMPLE	f
cmfkzc2zw0014i804fy3m9d9w	cmfkzc1o50001i804mtuty789	31	Supply of MPCB for Compressor WITH AUXILIARY CONTACTS 1 NO + 1\r\nNC SIDE MOUNTING.	Nos.	2400	2380	1758.34672		PARTIALLY_SENT	0	2025-09-15 10:26:58.986	2025-09-15 11:51:06.177	4589.469525823999	230.73328	0.3	4	1758.34672	1989.08	1266009.6384	\N	SIMPLE	f
cmfkzc2zw0015i804u34wz5to	cmfkzc1o50001i804mtuty789	32	Supply of MPCB for Condenser WITH AUXILIARY CONTACTS 1 NO + 1\r\nNC SIDE MOUNTING.	Nos.	2400	2380	896.1903599999999		PARTIALLY_SENT	0	2025-09-15 10:26:58.986	2025-09-15 11:51:06.179	1192.213390356	117.59964	0.25	4	896.1903599999999	1013.79	537714.216	\N	SIMPLE	f
cmfkzc2zw001ci804akze6wla	cmfkzc1o50001i804mtuty789	39	Supply of blower motor runner.	Set	1200	1140	10568.89184		PARTIALLY_SENT	0	2025-09-15 10:26:58.986	2025-09-15 11:51:06.181	165810.628726016	1386.86816	0.25	2	10568.89184	11955.76	3170667.552	\N	SIMPLE	f
\.


--
-- Data for Name: notifications; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.notifications (id, title, message, type, "isRead", "userId", "projectId", "lotId", "createdAt") FROM stdin;
cmfkzc1p10005i8047y0gutz1	📁 New Project Created	Project "Comprehensive Maintenance Contract of RMPU of ICF  AC coaches at Matunga Workshop,  Qty-600 coaches for period of 02 years" has been created successfully	SUCCESS	t	cmeve8gys0000s46d6wank1vs	cmfkzc1o50001i804mtuty789	\N	2025-09-15 10:26:57.301
cmfkzc2wa0009i804adnin278	📄 Document Uploaded	Document "AMC Matunga POH 2025-2026 Summary updated 08.09.25 .xlsx" has been uploaded successfully	DOCUMENT_RECEIVED	t	cmeve8gys0000s46d6wank1vs	cmfkzc1o50001i804mtuty789	\N	2025-09-15 10:26:58.858
cmfkzc3eb001gi8041smrkxmt	📄 Document Uploaded	Document "Top Sheet RITES Inspection.pdf" has been uploaded successfully	DOCUMENT_RECEIVED	t	cmeve8gys0000s46d6wank1vs	cmfkzc1o50001i804mtuty789	\N	2025-09-15 10:26:59.507
cmfl2c9v2000ojp046hjt49hm	📦 New Lot Created	Lot LOT-001 has been created	LOT_CREATED	t	cmeve8gys0000s46d6wank1vs	cmfkzc1o50001i804mtuty789	cmfl2c9dx0001jp04u9tl1048	2025-09-15 11:51:06.734
cmfqjpnmk0003ky04mvop7q9u	📧 Email Monitoring Started	Automated email monitoring has been started successfully. The system will now monitor for new inspection-related emails.	SUCCESS	t	cmeve8gys0000s46d6wank1vs	\N	\N	2025-09-19 07:56:15.452
cmfqjpuli0009ky04jkc9g71m	📧 Document Received from Email	Document "InternalTest Record.pdf" was fetched from email for Lot LOT-001 of project "Comprehensive Maintenance Contract of RMPU of ICF  AC coaches at Matunga Workshop,  Qty-600 coaches for period of 02 years" (PG/DTL/2024-22/OP/17)	SUCCESS	f	cmeve8gys0000s46d6wank1vs	cmfkzc1o50001i804mtuty789	cmfl2c9dx0001jp04u9tl1048	2025-09-19 07:56:24.487
cmfqjpuse000dky0423yngqax	📧 Document Received from Email	Document "checksheet and inspection data.pdf" was fetched from email for Lot LOT-001 of project "Comprehensive Maintenance Contract of RMPU of ICF  AC coaches at Matunga Workshop,  Qty-600 coaches for period of 02 years" (PG/DTL/2024-22/OP/17)	SUCCESS	f	cmeve8gys0000s46d6wank1vs	cmfkzc1o50001i804mtuty789	cmfl2c9dx0001jp04u9tl1048	2025-09-19 07:56:24.734
cmfqjpuwx000hky04hozkbf5o	📧 Document Received from Email	Document "call letter.pdf" was fetched from email for Lot LOT-001 of project "Comprehensive Maintenance Contract of RMPU of ICF  AC coaches at Matunga Workshop,  Qty-600 coaches for period of 02 years" (PG/DTL/2024-22/OP/17)	SUCCESS	f	cmeve8gys0000s46d6wank1vs	cmfkzc1o50001i804mtuty789	cmfl2c9dx0001jp04u9tl1048	2025-09-19 07:56:24.898
cmfqjpv26000lky04lgb14smn	📧 Document Received from Email	Document " Drawing Specification.pdf" was fetched from email for Lot LOT-001 of project "Comprehensive Maintenance Contract of RMPU of ICF  AC coaches at Matunga Workshop,  Qty-600 coaches for period of 02 years" (PG/DTL/2024-22/OP/17)	SUCCESS	f	cmeve8gys0000s46d6wank1vs	cmfkzc1o50001i804mtuty789	cmfl2c9dx0001jp04u9tl1048	2025-09-19 07:56:25.086
cmfqjpv6e000pky04dnkuji0f	📧 Document Received from Email	Document "PO copy with amendments.pdf" was fetched from email for Lot LOT-001 of project "Comprehensive Maintenance Contract of RMPU of ICF  AC coaches at Matunga Workshop,  Qty-600 coaches for period of 02 years" (PG/DTL/2024-22/OP/17)	SUCCESS	f	cmeve8gys0000s46d6wank1vs	cmfkzc1o50001i804mtuty789	cmfl2c9dx0001jp04u9tl1048	2025-09-19 07:56:25.238
cmfqjpxo9000vky04pa3ekxgo	📧 Document Received from Email	Document "calibration certificate.pdf" was fetched from email for Lot LOT-001 of project "Comprehensive Maintenance Contract of RMPU of ICF  AC coaches at Matunga Workshop,  Qty-600 coaches for period of 02 years" (PG/DTL/2024-22/OP/17)	SUCCESS	f	cmeve8gys0000s46d6wank1vs	cmfkzc1o50001i804mtuty789	cmfl2c9dx0001jp04u9tl1048	2025-09-19 07:56:28.473
cmfqjpxty000zky04bs8jfmra	📧 Documents Fetched from Email	5 documents fetched from email "Re: Document Request - Comprehensive Maintenance Contract of RMPU of ICF AC coaches at Matunga Workshop, Qty-600 coaches for period of 02 years - LOT-001 - AMC Documents" for Lot LOT-001 (PO: PG/DTL/2024-22/OP/17)	INFO	f	cmeve8gys0000s46d6wank1vs	\N	\N	2025-09-19 07:56:28.679
cmfqjpxu40011ky04xy0uu3nq	📧 Documents Fetched from Email	1 document fetched from email "Re: Document Request - Comprehensive Maintenance Contract of RMPU of ICF AC coaches at Matunga Workshop, Qty-600 coaches for period of 02 years - LOT-001 - Calibration Documents" for Lot LOT-001 (PO: PG/DTL/2024-22/OP/17)	INFO	f	cmeve8gys0000s46d6wank1vs	\N	\N	2025-09-19 07:56:28.685
\.


--
-- Data for Name: project_departments; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.project_departments (id, "projectId", "departmentId") FROM stdin;
\.


--
-- Data for Name: projects; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.projects (id, title, "poNumber", "startDate", "endDate", "tenderDate", status, progress, "totalValue", "createdAt", "updatedAt", "managerId", "categoryId", "clientId", "inspectionAgencyId") FROM stdin;
cmfkzc1o50001i804mtuty789	Comprehensive Maintenance Contract of RMPU of ICF  AC coaches at Matunga Workshop,  Qty-600 coaches for period of 02 years	PG/DTL/2024-22/OP/17	2025-03-12 00:00:00	2027-03-11 00:00:00	2025-09-15 10:26:57.265	ACTIVE	5	96092863.86	2025-09-15 10:26:57.269	2025-09-15 10:26:58.578	cmeve8gys0000s46d6wank1vs	cmfkrqof20000l50418rl9shb	cmfkz62xg0000l404u4gn20y1	cmeve8l6t000as46ddrm24brm
\.


--
-- Data for Name: stakeholders; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.stakeholders (id, name, "isActive", "createdAt", "updatedAt") FROM stdin;
cmfl0lobq0000jr04w6039bvu	Sachin Kumar Singh	t	2025-09-15 11:02:26.15	2025-09-15 11:02:26.15
cmfl7gjmh0000la04kq7aooph	Ayush Som	t	2025-09-15 14:14:24.089	2025-09-15 14:14:24.089
\.


--
-- Data for Name: suppliers; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.suppliers (id, name, email, "isActive", "createdAt", "updatedAt") FROM stdin;
cmex525fc0000l204r8hsn1wo	make	\N	t	2025-08-29 18:00:45.049	2025-08-29 18:00:45.049
cmex529mc0003l2044nly5gz2	3M	\N	t	2025-08-29 18:00:50.485	2025-08-29 18:00:50.485
cmf0k77vs0000l5043ozh6e44	Resistoflex	\N	t	2025-09-01 03:27:54.281	2025-09-01 03:27:54.281
cmf0k7e860003l504dtwq2suj	usha	\N	t	2025-09-01 03:28:02.502	2025-09-01 03:28:02.502
cmf0k7msi0006l50436vam2j0	Delkon	\N	t	2025-09-01 03:28:13.602	2025-09-01 03:28:13.602
cmf0k849k0009l5040faci53j	Danfoss	\N	t	2025-09-01 03:28:36.248	2025-09-01 03:28:36.248
cmf0k8nau000el504niizkvwf	Max Micro System	\N	t	2025-09-01 03:29:00.918	2025-09-01 03:29:00.918
cmf0k8zyi000hl5043skr1076	BCH	\N	t	2025-09-01 03:29:17.322	2025-09-01 03:29:17.322
cmf0k9j3q000ml504jbf7kev1	Blowtech	\N	t	2025-09-01 03:29:42.134	2025-09-01 03:29:42.134
cmfkzitov0000l20497qxnr32	Navair	\N	t	2025-09-15 10:32:13.52	2025-09-15 10:32:13.52
cmfkzkmrg0000l204m21z4i4t	STAR	\N	t	2025-09-15 10:33:37.852	2025-09-15 10:33:37.852
cmfkzqh3m0002jp04qiielyvf	Everfine	\N	t	2025-09-15 10:38:10.451	2025-09-15 10:38:10.451
cmfkzr9ia0000jr04r6la3o08	PRIJAI	\N	t	2025-09-15 10:38:47.267	2025-09-15 10:38:47.267
cmfkztb220000jr04y7z3xvka	EMERSON	\N	t	2025-09-15 10:40:22.586	2025-09-15 10:40:22.586
cmfkzys8t0000jr04zwbkqiji	PRAG MAKE	\N	t	2025-09-15 10:44:38.142	2025-09-15 10:44:38.142
cmfl00bge0000jp04h4em708w	MAX MICRO SYSTEMS	\N	t	2025-09-15 10:45:49.695	2025-09-15 10:45:49.695
cmfl00oew0003jp04ie7vni0r	HARTING	\N	t	2025-09-15 10:46:06.489	2025-09-15 10:46:06.489
cmfl01zzz0003jr04ri3f88j1	A PAUL	\N	t	2025-09-15 10:47:08.16	2025-09-15 10:47:08.16
cmfl02bz00006jr042lbgrkdi	ALERT	\N	t	2025-09-15 10:47:23.676	2025-09-15 10:47:23.676
cmfl09mjc0002jp04aatytab0	SIDWAL	\N	t	2025-09-15 10:53:03.961	2025-09-15 10:53:03.961
cmfl0aedb0005jp04orearo6t	KAYCEE	\N	t	2025-09-15 10:53:40.032	2025-09-15 10:53:40.032
cmfl0fk5c0000jr04tvd4di6b	LEGRAND	\N	t	2025-09-15 10:57:40.8	2025-09-15 10:57:40.8
cmfl0glc80000jp04exag7vqc	ABB	\N	t	2025-09-15 10:58:29	2025-09-15 10:58:29
cmfl0gs6x0003jp04ystia0qj	SIEMENS	\N	t	2025-09-15 10:58:37.882	2025-09-15 10:58:37.882
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.users (id, email, name, password, role, department, "isActive", "twoFactorEnabled", "createdAt", "updatedAt", "gmailTokens") FROM stdin;
cmeve8hon0001s46dt12fj7d1	manager@example.com	Rajesh Kumar	$2b$12$OU2CMvUQGJFGf8dNH4qVO.3/4ltDeIlYLCNLC5op7/hrb6GxuPDzy	PROJECT_MANAGER	Project Management	t	f	2025-08-28 12:42:05.064	2025-08-28 12:42:05.064	\N
cmeve8i4b0002s46d823zy9v0	store@example.com	Store Manager	$2b$12$6BU8DBGVEDfoUGv4i7WonecGCVSMtcBBHJSAZ2MBT6L2Sbne9oaW6	DEPARTMENT_HEAD	Store	t	f	2025-08-28 12:42:05.627	2025-08-28 12:42:05.627	\N
cmeve8ik00003s46dzg3ab8qo	maintenance@example.com	Maintenance Manager	$2b$12$lFSsOojAXoqeh2zkWhw2ku/BkvL5Mvaa9itBzkpCMlUxE0qEDfiQG	DEPARTMENT_HEAD	Maintenance	t	f	2025-08-28 12:42:06.193	2025-08-28 12:42:06.193	\N
cmeve8izy0004s46dmsucnkbr	inspector@example.com	Quality Inspector	$2b$12$X38vUK7zripOY61XMAJMa.gvXZmQfj9MxVoeFpXjbBOQ1ePNxBAt.	INSPECTOR	Quality	t	f	2025-08-28 12:42:06.766	2025-08-28 12:42:06.766	\N
cmeve8jf20005s46dnpnuu2g4	viewer@example.com	Read-Only User	$2b$12$mReC6RNvSu/Y9B.cKyZey.By0TObYiByHdU98DkkV4hUo5kFceHfS	VIEWER	Viewing	t	f	2025-08-28 12:42:07.31	2025-08-28 12:42:07.31	\N
cmeve8gys0000s46d6wank1vs	sachinsinghmtqm@gmail.com	Admin User	$2b$12$ozRiqtn/2DZWqXlkfxzAP.oCOBgvV1RU/NiN1jfMAzAzPPvofpD/u	ADMIN	Administration	t	f	2025-08-28 12:42:04.133	2025-09-15 11:51:06.408	{"expiryDate": 1757940665406, "accessToken": "ya29.a0AS3H6NwnN3HV2WJrPkIgGGYje42yzZCD1QH2lpOVOdSPdUy5Re78X9kZLPHsv1CaoUz383OMiAhdCQxURo3xYcVrfYpyPYkxkmzbjiQRBVwzQqhZDayKXIHvQhhbk_L5ZV7cl4u6q3mHdruS2ozykSrch9H89_GYqUyLRQ21Q10HyXjSuvVrvoB9ofG1C8eSL_Gp_PcaCgYKAZESARISFQHGX2MiXT-JoUkYqbgm86Iu_0rgxQ0206", "authorizedAt": "2025-09-15T10:17:30.559Z", "refreshToken": "1//056M0js0grtgqCgYIARAAGAUSNwF-L9IrcIg2m_-dDn1YIAerskUnyuwHAgM0mEGjENEsBAvjEPfv-bXc1ycBoi-KuDh74VBUjeU", "authorizedEmail": "sachinsinghmtqm@gmail.com"}
\.


--
-- Name: audit_logs audit_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.audit_logs
    ADD CONSTRAINT audit_logs_pkey PRIMARY KEY (id);


--
-- Name: categories categories_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.categories
    ADD CONSTRAINT categories_pkey PRIMARY KEY (id);


--
-- Name: clients clients_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.clients
    ADD CONSTRAINT clients_pkey PRIMARY KEY (id);


--
-- Name: departments departments_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.departments
    ADD CONSTRAINT departments_pkey PRIMARY KEY (id);


--
-- Name: document_alternatives document_alternatives_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.document_alternatives
    ADD CONSTRAINT document_alternatives_pkey PRIMARY KEY (id);


--
-- Name: document_requirements document_requirements_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.document_requirements
    ADD CONSTRAINT document_requirements_pkey PRIMARY KEY (id);


--
-- Name: documents documents_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.documents
    ADD CONSTRAINT documents_pkey PRIMARY KEY (id);


--
-- Name: email_logs email_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.email_logs
    ADD CONSTRAINT email_logs_pkey PRIMARY KEY (id);


--
-- Name: extracted_document_requirements extracted_document_requirements_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.extracted_document_requirements
    ADD CONSTRAINT extracted_document_requirements_pkey PRIMARY KEY (id);


--
-- Name: inspection_agencies inspection_agencies_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.inspection_agencies
    ADD CONSTRAINT inspection_agencies_pkey PRIMARY KEY (id);


--
-- Name: invoice_items invoice_items_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.invoice_items
    ADD CONSTRAINT invoice_items_pkey PRIMARY KEY (id);


--
-- Name: invoices invoices_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_pkey PRIMARY KEY (id);


--
-- Name: item_suppliers item_suppliers_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.item_suppliers
    ADD CONSTRAINT item_suppliers_pkey PRIMARY KEY (id);


--
-- Name: lot_items lot_items_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.lot_items
    ADD CONSTRAINT lot_items_pkey PRIMARY KEY (id);


--
-- Name: lot_revisions lot_revisions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.lot_revisions
    ADD CONSTRAINT lot_revisions_pkey PRIMARY KEY (id);


--
-- Name: lots lots_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.lots
    ADD CONSTRAINT lots_pkey PRIMARY KEY (id);


--
-- Name: master_items master_items_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.master_items
    ADD CONSTRAINT master_items_pkey PRIMARY KEY (id);


--
-- Name: notifications notifications_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT notifications_pkey PRIMARY KEY (id);


--
-- Name: project_departments project_departments_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.project_departments
    ADD CONSTRAINT project_departments_pkey PRIMARY KEY (id);


--
-- Name: projects projects_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.projects
    ADD CONSTRAINT projects_pkey PRIMARY KEY (id);


--
-- Name: stakeholders stakeholders_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.stakeholders
    ADD CONSTRAINT stakeholders_pkey PRIMARY KEY (id);


--
-- Name: suppliers suppliers_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.suppliers
    ADD CONSTRAINT suppliers_pkey PRIMARY KEY (id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: audit_logs_createdAt_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "audit_logs_createdAt_idx" ON public.audit_logs USING btree ("createdAt");


--
-- Name: audit_logs_entity_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX audit_logs_entity_idx ON public.audit_logs USING btree (entity);


--
-- Name: audit_logs_projectId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "audit_logs_projectId_idx" ON public.audit_logs USING btree ("projectId");


--
-- Name: audit_logs_userId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "audit_logs_userId_idx" ON public.audit_logs USING btree ("userId");


--
-- Name: categories_name_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX categories_name_key ON public.categories USING btree (name);


--
-- Name: clients_name_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX clients_name_key ON public.clients USING btree (name);


--
-- Name: departments_code_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX departments_code_key ON public.departments USING btree (code);


--
-- Name: departments_name_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX departments_name_key ON public.departments USING btree (name);


--
-- Name: document_alternatives_projectId_primaryDocumentRequirementI_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "document_alternatives_projectId_primaryDocumentRequirementI_key" ON public.document_alternatives USING btree ("projectId", "primaryDocumentRequirementId", "alternativeName");


--
-- Name: documents_createdAt_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "documents_createdAt_idx" ON public.documents USING btree ("createdAt");


--
-- Name: documents_documentType_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "documents_documentType_idx" ON public.documents USING btree ("documentType");


--
-- Name: documents_isVendorInvoice_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "documents_isVendorInvoice_idx" ON public.documents USING btree ("isVendorInvoice");


--
-- Name: documents_mimeType_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "documents_mimeType_idx" ON public.documents USING btree ("mimeType");


--
-- Name: documents_originalDocumentId_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "documents_originalDocumentId_key" ON public.documents USING btree ("originalDocumentId");


--
-- Name: documents_projectId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "documents_projectId_idx" ON public.documents USING btree ("projectId");


--
-- Name: documents_projectId_status_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "documents_projectId_status_idx" ON public.documents USING btree ("projectId", status);


--
-- Name: documents_redactedDocumentId_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "documents_redactedDocumentId_key" ON public.documents USING btree ("redactedDocumentId");


--
-- Name: documents_status_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX documents_status_idx ON public.documents USING btree (status);


--
-- Name: inspection_agencies_name_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX inspection_agencies_name_key ON public.inspection_agencies USING btree (name);


--
-- Name: invoices_invoiceDate_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "invoices_invoiceDate_idx" ON public.invoices USING btree ("invoiceDate");


--
-- Name: invoices_invoiceNumber_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "invoices_invoiceNumber_key" ON public.invoices USING btree ("invoiceNumber");


--
-- Name: invoices_lotId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "invoices_lotId_idx" ON public.invoices USING btree ("lotId");


--
-- Name: invoices_projectId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "invoices_projectId_idx" ON public.invoices USING btree ("projectId");


--
-- Name: invoices_status_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX invoices_status_idx ON public.invoices USING btree (status);


--
-- Name: item_suppliers_masterItemId_supplierId_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "item_suppliers_masterItemId_supplierId_key" ON public.item_suppliers USING btree ("masterItemId", "supplierId");


--
-- Name: lot_items_lotId_masterItemId_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "lot_items_lotId_masterItemId_key" ON public.lot_items USING btree ("lotId", "masterItemId");


--
-- Name: lots_createdAt_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "lots_createdAt_idx" ON public.lots USING btree ("createdAt");


--
-- Name: lots_projectId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "lots_projectId_idx" ON public.lots USING btree ("projectId");


--
-- Name: lots_projectId_lotNumber_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "lots_projectId_lotNumber_key" ON public.lots USING btree ("projectId", "lotNumber");


--
-- Name: lots_projectId_status_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "lots_projectId_status_idx" ON public.lots USING btree ("projectId", status);


--
-- Name: lots_status_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX lots_status_idx ON public.lots USING btree (status);


--
-- Name: master_items_projectId_serialNumber_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "master_items_projectId_serialNumber_key" ON public.master_items USING btree ("projectId", "serialNumber");


--
-- Name: project_departments_projectId_departmentId_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "project_departments_projectId_departmentId_key" ON public.project_departments USING btree ("projectId", "departmentId");


--
-- Name: projects_createdAt_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "projects_createdAt_idx" ON public.projects USING btree ("createdAt");


--
-- Name: projects_managerId_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "projects_managerId_idx" ON public.projects USING btree ("managerId");


--
-- Name: projects_poNumber_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "projects_poNumber_key" ON public.projects USING btree ("poNumber");


--
-- Name: projects_status_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX projects_status_idx ON public.projects USING btree (status);


--
-- Name: stakeholders_name_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX stakeholders_name_key ON public.stakeholders USING btree (name);


--
-- Name: suppliers_name_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX suppliers_name_key ON public.suppliers USING btree (name);


--
-- Name: users_email_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX users_email_key ON public.users USING btree (email);


--
-- Name: audit_logs audit_logs_invoiceId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.audit_logs
    ADD CONSTRAINT "audit_logs_invoiceId_fkey" FOREIGN KEY ("invoiceId") REFERENCES public.invoices(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: audit_logs audit_logs_lotId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.audit_logs
    ADD CONSTRAINT "audit_logs_lotId_fkey" FOREIGN KEY ("lotId") REFERENCES public.lots(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: audit_logs audit_logs_projectId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.audit_logs
    ADD CONSTRAINT "audit_logs_projectId_fkey" FOREIGN KEY ("projectId") REFERENCES public.projects(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: audit_logs audit_logs_userId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.audit_logs
    ADD CONSTRAINT "audit_logs_userId_fkey" FOREIGN KEY ("userId") REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: document_alternatives document_alternatives_primaryDocumentRequirementId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.document_alternatives
    ADD CONSTRAINT "document_alternatives_primaryDocumentRequirementId_fkey" FOREIGN KEY ("primaryDocumentRequirementId") REFERENCES public.extracted_document_requirements(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: document_alternatives document_alternatives_projectId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.document_alternatives
    ADD CONSTRAINT "document_alternatives_projectId_fkey" FOREIGN KEY ("projectId") REFERENCES public.projects(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: document_requirements document_requirements_projectDepartmentId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.document_requirements
    ADD CONSTRAINT "document_requirements_projectDepartmentId_fkey" FOREIGN KEY ("projectDepartmentId") REFERENCES public.project_departments(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: documents documents_departmentId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.documents
    ADD CONSTRAINT "documents_departmentId_fkey" FOREIGN KEY ("departmentId") REFERENCES public.departments(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: documents documents_documentRequirementId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.documents
    ADD CONSTRAINT "documents_documentRequirementId_fkey" FOREIGN KEY ("documentRequirementId") REFERENCES public.document_requirements(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: documents documents_lotId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.documents
    ADD CONSTRAINT "documents_lotId_fkey" FOREIGN KEY ("lotId") REFERENCES public.lots(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: documents documents_masterItemId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.documents
    ADD CONSTRAINT "documents_masterItemId_fkey" FOREIGN KEY ("masterItemId") REFERENCES public.master_items(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: documents documents_originalDocumentId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.documents
    ADD CONSTRAINT "documents_originalDocumentId_fkey" FOREIGN KEY ("originalDocumentId") REFERENCES public.documents(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: documents documents_projectId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.documents
    ADD CONSTRAINT "documents_projectId_fkey" FOREIGN KEY ("projectId") REFERENCES public.projects(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: documents documents_uploadedById_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.documents
    ADD CONSTRAINT "documents_uploadedById_fkey" FOREIGN KEY ("uploadedById") REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: email_logs email_logs_lotId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.email_logs
    ADD CONSTRAINT "email_logs_lotId_fkey" FOREIGN KEY ("lotId") REFERENCES public.lots(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: email_logs email_logs_projectId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.email_logs
    ADD CONSTRAINT "email_logs_projectId_fkey" FOREIGN KEY ("projectId") REFERENCES public.projects(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: email_logs email_logs_userId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.email_logs
    ADD CONSTRAINT "email_logs_userId_fkey" FOREIGN KEY ("userId") REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: extracted_document_requirements extracted_document_requirements_projectId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.extracted_document_requirements
    ADD CONSTRAINT "extracted_document_requirements_projectId_fkey" FOREIGN KEY ("projectId") REFERENCES public.projects(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: invoice_items invoice_items_invoiceId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.invoice_items
    ADD CONSTRAINT "invoice_items_invoiceId_fkey" FOREIGN KEY ("invoiceId") REFERENCES public.invoices(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: invoice_items invoice_items_lotItemId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.invoice_items
    ADD CONSTRAINT "invoice_items_lotItemId_fkey" FOREIGN KEY ("lotItemId") REFERENCES public.lot_items(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: invoice_items invoice_items_masterItemId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.invoice_items
    ADD CONSTRAINT "invoice_items_masterItemId_fkey" FOREIGN KEY ("masterItemId") REFERENCES public.master_items(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: invoices invoices_approvedById_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT "invoices_approvedById_fkey" FOREIGN KEY ("approvedById") REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: invoices invoices_createdById_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT "invoices_createdById_fkey" FOREIGN KEY ("createdById") REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: invoices invoices_documentId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT "invoices_documentId_fkey" FOREIGN KEY ("documentId") REFERENCES public.documents(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: invoices invoices_lotId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT "invoices_lotId_fkey" FOREIGN KEY ("lotId") REFERENCES public.lots(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: invoices invoices_projectId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT "invoices_projectId_fkey" FOREIGN KEY ("projectId") REFERENCES public.projects(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: invoices invoices_supplierId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT "invoices_supplierId_fkey" FOREIGN KEY ("supplierId") REFERENCES public.suppliers(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: item_suppliers item_suppliers_masterItemId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.item_suppliers
    ADD CONSTRAINT "item_suppliers_masterItemId_fkey" FOREIGN KEY ("masterItemId") REFERENCES public.master_items(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: item_suppliers item_suppliers_supplierId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.item_suppliers
    ADD CONSTRAINT "item_suppliers_supplierId_fkey" FOREIGN KEY ("supplierId") REFERENCES public.suppliers(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: lot_items lot_items_lotId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.lot_items
    ADD CONSTRAINT "lot_items_lotId_fkey" FOREIGN KEY ("lotId") REFERENCES public.lots(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: lot_items lot_items_masterItemId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.lot_items
    ADD CONSTRAINT "lot_items_masterItemId_fkey" FOREIGN KEY ("masterItemId") REFERENCES public.master_items(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: lot_items lot_items_selectedSupplierId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.lot_items
    ADD CONSTRAINT "lot_items_selectedSupplierId_fkey" FOREIGN KEY ("selectedSupplierId") REFERENCES public.suppliers(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: lot_revisions lot_revisions_approvedById_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.lot_revisions
    ADD CONSTRAINT "lot_revisions_approvedById_fkey" FOREIGN KEY ("approvedById") REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: lot_revisions lot_revisions_lotId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.lot_revisions
    ADD CONSTRAINT "lot_revisions_lotId_fkey" FOREIGN KEY ("lotId") REFERENCES public.lots(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: lot_revisions lot_revisions_masterItemId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.lot_revisions
    ADD CONSTRAINT "lot_revisions_masterItemId_fkey" FOREIGN KEY ("masterItemId") REFERENCES public.master_items(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: lot_revisions lot_revisions_requestedById_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.lot_revisions
    ADD CONSTRAINT "lot_revisions_requestedById_fkey" FOREIGN KEY ("requestedById") REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: lots lots_createdById_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.lots
    ADD CONSTRAINT "lots_createdById_fkey" FOREIGN KEY ("createdById") REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: lots lots_projectId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.lots
    ADD CONSTRAINT "lots_projectId_fkey" FOREIGN KEY ("projectId") REFERENCES public.projects(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: master_items master_items_projectId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.master_items
    ADD CONSTRAINT "master_items_projectId_fkey" FOREIGN KEY ("projectId") REFERENCES public.projects(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: notifications notifications_lotId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT "notifications_lotId_fkey" FOREIGN KEY ("lotId") REFERENCES public.lots(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: notifications notifications_projectId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT "notifications_projectId_fkey" FOREIGN KEY ("projectId") REFERENCES public.projects(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: notifications notifications_userId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT "notifications_userId_fkey" FOREIGN KEY ("userId") REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: project_departments project_departments_departmentId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.project_departments
    ADD CONSTRAINT "project_departments_departmentId_fkey" FOREIGN KEY ("departmentId") REFERENCES public.departments(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: project_departments project_departments_projectId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.project_departments
    ADD CONSTRAINT "project_departments_projectId_fkey" FOREIGN KEY ("projectId") REFERENCES public.projects(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: projects projects_categoryId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.projects
    ADD CONSTRAINT "projects_categoryId_fkey" FOREIGN KEY ("categoryId") REFERENCES public.categories(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: projects projects_clientId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.projects
    ADD CONSTRAINT "projects_clientId_fkey" FOREIGN KEY ("clientId") REFERENCES public.clients(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: projects projects_inspectionAgencyId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.projects
    ADD CONSTRAINT "projects_inspectionAgencyId_fkey" FOREIGN KEY ("inspectionAgencyId") REFERENCES public.inspection_agencies(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: projects projects_managerId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.projects
    ADD CONSTRAINT "projects_managerId_fkey" FOREIGN KEY ("managerId") REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- PostgreSQL database dump complete
--

