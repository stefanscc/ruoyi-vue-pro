--
-- PostgreSQL database dump
--

\restrict IbZil85aeeQPdVheeYpJJzpBvaUbw7BS3rdYOmigOkCtLFSBipkrdUtnysROevB

-- Dumped from database version 16.13 (Debian 16.13-1.pgdg13+1)
-- Dumped by pg_dump version 16.13 (Debian 16.13-1.pgdg13+1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: dual; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.dual (
    id smallint
);


--
-- Name: TABLE dual; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.dual IS '鏁版嵁搴撹繛鎺ョ殑琛?;


--
-- Name: infra_api_access_log; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.infra_api_access_log (
    id bigint NOT NULL,
    trace_id character varying(64) DEFAULT ''::character varying NOT NULL,
    user_id bigint DEFAULT 0 NOT NULL,
    user_type smallint DEFAULT 0 NOT NULL,
    application_name character varying(50) NOT NULL,
    request_method character varying(16) DEFAULT ''::character varying NOT NULL,
    request_url character varying(255) DEFAULT ''::character varying NOT NULL,
    request_params text,
    response_body text,
    user_ip character varying(50) NOT NULL,
    user_agent character varying(512) NOT NULL,
    operate_module character varying(50) DEFAULT NULL::character varying,
    operate_name character varying(50) DEFAULT NULL::character varying,
    operate_type smallint DEFAULT 0,
    begin_time timestamp without time zone NOT NULL,
    end_time timestamp without time zone NOT NULL,
    duration integer NOT NULL,
    result_code integer DEFAULT 0 NOT NULL,
    result_msg character varying(512) DEFAULT ''::character varying,
    creator character varying(64) DEFAULT ''::character varying,
    create_time timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updater character varying(64) DEFAULT ''::character varying,
    update_time timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    deleted smallint DEFAULT 0 NOT NULL
);


--
-- Name: TABLE infra_api_access_log; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.infra_api_access_log IS 'API 璁块棶鏃ュ織琛?;


--
-- Name: COLUMN infra_api_access_log.id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.infra_api_access_log.id IS '鏃ュ織涓婚敭';


--
-- Name: COLUMN infra_api_access_log.trace_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.infra_api_access_log.trace_id IS '閾捐矾杩借釜缂栧彿';


--
-- Name: COLUMN infra_api_access_log.user_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.infra_api_access_log.user_id IS '鐢ㄦ埛缂栧彿';


--
-- Name: COLUMN infra_api_access_log.user_type; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.infra_api_access_log.user_type IS '鐢ㄦ埛绫诲瀷';


--
-- Name: COLUMN infra_api_access_log.application_name; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.infra_api_access_log.application_name IS '搴旂敤鍚?;


--
-- Name: COLUMN infra_api_access_log.request_method; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.infra_api_access_log.request_method IS '璇锋眰鏂规硶鍚?;


--
-- Name: COLUMN infra_api_access_log.request_url; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.infra_api_access_log.request_url IS '璇锋眰鍦板潃';


--
-- Name: COLUMN infra_api_access_log.request_params; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.infra_api_access_log.request_params IS '璇锋眰鍙傛暟';


--
-- Name: COLUMN infra_api_access_log.response_body; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.infra_api_access_log.response_body IS '鍝嶅簲缁撴灉';


--
-- Name: COLUMN infra_api_access_log.user_ip; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.infra_api_access_log.user_ip IS '鐢ㄦ埛 IP';


--
-- Name: COLUMN infra_api_access_log.user_agent; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.infra_api_access_log.user_agent IS '娴忚鍣?UA';


--
-- Name: COLUMN infra_api_access_log.operate_module; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.infra_api_access_log.operate_module IS '鎿嶄綔妯″潡';


--
-- Name: COLUMN infra_api_access_log.operate_name; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.infra_api_access_log.operate_name IS '鎿嶄綔鍚?;


--
-- Name: COLUMN infra_api_access_log.operate_type; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.infra_api_access_log.operate_type IS '鎿嶄綔鍒嗙被';


--
-- Name: COLUMN infra_api_access_log.begin_time; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.infra_api_access_log.begin_time IS '寮€濮嬭姹傛椂闂?;


--
-- Name: COLUMN infra_api_access_log.end_time; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.infra_api_access_log.end_time IS '缁撴潫璇锋眰鏃堕棿';


--
-- Name: COLUMN infra_api_access_log.duration; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.infra_api_access_log.duration IS '鎵ц鏃堕暱';


--
-- Name: COLUMN infra_api_access_log.result_code; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.infra_api_access_log.result_code IS '缁撴灉鐮?;


--
-- Name: COLUMN infra_api_access_log.result_msg; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.infra_api_access_log.result_msg IS '缁撴灉鎻愮ず';


--
-- Name: COLUMN infra_api_access_log.creator; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.infra_api_access_log.creator IS '鍒涘缓鑰?;


--
-- Name: COLUMN infra_api_access_log.create_time; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.infra_api_access_log.create_time IS '鍒涘缓鏃堕棿';


--
-- Name: COLUMN infra_api_access_log.updater; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.infra_api_access_log.updater IS '鏇存柊鑰?;


--
-- Name: COLUMN infra_api_access_log.update_time; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.infra_api_access_log.update_time IS '鏇存柊鏃堕棿';


--
-- Name: COLUMN infra_api_access_log.deleted; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.infra_api_access_log.deleted IS '鏄惁鍒犻櫎';



--
-- Name: infra_api_access_log_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.infra_api_access_log_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: infra_api_error_log; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.infra_api_error_log (
    id bigint NOT NULL,
    trace_id character varying(64) NOT NULL,
    user_id bigint DEFAULT 0 NOT NULL,
    user_type smallint DEFAULT 0 NOT NULL,
    application_name character varying(50) NOT NULL,
    request_method character varying(16) NOT NULL,
    request_url character varying(255) NOT NULL,
    request_params character varying(8000) NOT NULL,
    user_ip character varying(50) NOT NULL,
    user_agent character varying(512) NOT NULL,
    exception_time timestamp without time zone NOT NULL,
    exception_name character varying(128) DEFAULT ''::character varying NOT NULL,
    exception_message text NOT NULL,
    exception_root_cause_message text NOT NULL,
    exception_stack_trace text NOT NULL,
    exception_class_name character varying(512) NOT NULL,
    exception_file_name character varying(512) NOT NULL,
    exception_method_name character varying(512) NOT NULL,
    exception_line_number integer NOT NULL,
    process_status smallint NOT NULL,
    process_time timestamp without time zone,
    process_user_id integer DEFAULT 0,
    creator character varying(64) DEFAULT ''::character varying,
    create_time timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updater character varying(64) DEFAULT ''::character varying,
    update_time timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    deleted smallint DEFAULT 0 NOT NULL
);


--
-- Name: TABLE infra_api_error_log; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.infra_api_error_log IS '绯荤粺寮傚父鏃ュ織';


--
-- Name: COLUMN infra_api_error_log.id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.infra_api_error_log.id IS '缂栧彿';


--
-- Name: COLUMN infra_api_error_log.trace_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.infra_api_error_log.trace_id IS '閾捐矾杩借釜缂栧彿';


--
-- Name: COLUMN infra_api_error_log.user_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.infra_api_error_log.user_id IS '鐢ㄦ埛缂栧彿';


--
-- Name: COLUMN infra_api_error_log.user_type; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.infra_api_error_log.user_type IS '鐢ㄦ埛绫诲瀷';


--
-- Name: COLUMN infra_api_error_log.application_name; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.infra_api_error_log.application_name IS '搴旂敤鍚?;


--
-- Name: COLUMN infra_api_error_log.request_method; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.infra_api_error_log.request_method IS '璇锋眰鏂规硶鍚?;


--
-- Name: COLUMN infra_api_error_log.request_url; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.infra_api_error_log.request_url IS '璇锋眰鍦板潃';


--
-- Name: COLUMN infra_api_error_log.request_params; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.infra_api_error_log.request_params IS '璇锋眰鍙傛暟';


--
-- Name: COLUMN infra_api_error_log.user_ip; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.infra_api_error_log.user_ip IS '鐢ㄦ埛 IP';


--
-- Name: COLUMN infra_api_error_log.user_agent; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.infra_api_error_log.user_agent IS '娴忚鍣?UA';


--
-- Name: COLUMN infra_api_error_log.exception_time; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.infra_api_error_log.exception_time IS '寮傚父鍙戠敓鏃堕棿';


--
-- Name: COLUMN infra_api_error_log.exception_name; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.infra_api_error_log.exception_name IS '寮傚父鍚?;


--
-- Name: COLUMN infra_api_error_log.exception_message; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.infra_api_error_log.exception_message IS '寮傚父瀵艰嚧鐨勬秷鎭?;


--
-- Name: COLUMN infra_api_error_log.exception_root_cause_message; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.infra_api_error_log.exception_root_cause_message IS '寮傚父瀵艰嚧鐨勬牴娑堟伅';


--
-- Name: COLUMN infra_api_error_log.exception_stack_trace; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.infra_api_error_log.exception_stack_trace IS '寮傚父鐨勬爤杞ㄨ抗';


--
-- Name: COLUMN infra_api_error_log.exception_class_name; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.infra_api_error_log.exception_class_name IS '寮傚父鍙戠敓鐨勭被鍏ㄥ悕';


--
-- Name: COLUMN infra_api_error_log.exception_file_name; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.infra_api_error_log.exception_file_name IS '寮傚父鍙戠敓鐨勭被鏂囦欢';


--
-- Name: COLUMN infra_api_error_log.exception_method_name; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.infra_api_error_log.exception_method_name IS '寮傚父鍙戠敓鐨勬柟娉曞悕';


--
-- Name: COLUMN infra_api_error_log.exception_line_number; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.infra_api_error_log.exception_line_number IS '寮傚父鍙戠敓鐨勬柟娉曟墍鍦ㄨ';


--
-- Name: COLUMN infra_api_error_log.process_status; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.infra_api_error_log.process_status IS '澶勭悊鐘舵€?;


--
-- Name: COLUMN infra_api_error_log.process_time; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.infra_api_error_log.process_time IS '澶勭悊鏃堕棿';


--
-- Name: COLUMN infra_api_error_log.process_user_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.infra_api_error_log.process_user_id IS '澶勭悊鐢ㄦ埛缂栧彿';


--
-- Name: COLUMN infra_api_error_log.creator; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.infra_api_error_log.creator IS '鍒涘缓鑰?;


--
-- Name: COLUMN infra_api_error_log.create_time; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.infra_api_error_log.create_time IS '鍒涘缓鏃堕棿';


--
-- Name: COLUMN infra_api_error_log.updater; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.infra_api_error_log.updater IS '鏇存柊鑰?;


--
-- Name: COLUMN infra_api_error_log.update_time; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.infra_api_error_log.update_time IS '鏇存柊鏃堕棿';


--
-- Name: COLUMN infra_api_error_log.deleted; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.infra_api_error_log.deleted IS '鏄惁鍒犻櫎';



--
-- Name: infra_api_error_log_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.infra_api_error_log_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: infra_file; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.infra_file (
    id bigint NOT NULL,
    name character varying(256) NOT NULL,
    path character varying(512) NOT NULL,
    url character varying(1024) NOT NULL,
    type character varying(255) DEFAULT ''::character varying,
    size bigint NOT NULL,
    creator character varying(64) DEFAULT ''::character varying,
    create_time timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updater character varying(64) DEFAULT ''::character varying,
    update_time timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    deleted smallint DEFAULT 0 NOT NULL
);


--
-- Name: TABLE infra_file; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.infra_file IS '鏂囦欢琛?;


--
-- Name: COLUMN infra_file.id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.infra_file.id IS '鏂囦欢缂栧彿';


--
-- Name: COLUMN infra_file.name; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.infra_file.name IS '鍘熸枃浠跺悕';


--
-- Name: COLUMN infra_file.path; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.infra_file.path IS '鏂囦欢璺緞';


--
-- Name: COLUMN infra_file.url; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.infra_file.url IS '鏂囦欢 URL';


--
-- Name: COLUMN infra_file.type; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.infra_file.type IS '鏂囦欢绫诲瀷';


--
-- Name: COLUMN infra_file.size; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.infra_file.size IS '鏂囦欢澶у皬';


--
-- Name: COLUMN infra_file.creator; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.infra_file.creator IS '鍒涘缓鑰?;


--
-- Name: COLUMN infra_file.create_time; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.infra_file.create_time IS '鍒涘缓鏃堕棿';


--
-- Name: COLUMN infra_file.updater; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.infra_file.updater IS '鏇存柊鑰?;


--
-- Name: COLUMN infra_file.update_time; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.infra_file.update_time IS '鏇存柊鏃堕棿';


--
-- Name: COLUMN infra_file.deleted; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.infra_file.deleted IS '鏄惁鍒犻櫎';


--
-- Name: infra_file_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.infra_file_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;



--
-- Name: infra_job; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.infra_job (
    id bigint NOT NULL,
    name character varying(32) NOT NULL,
    status smallint NOT NULL,
    handler_name character varying(64) NOT NULL,
    handler_param character varying(255) DEFAULT NULL::character varying,
    cron_expression character varying(32) NOT NULL,
    retry_count integer DEFAULT 0 NOT NULL,
    retry_interval integer DEFAULT 0 NOT NULL,
    monitor_timeout integer DEFAULT 0 NOT NULL,
    creator character varying(64) DEFAULT ''::character varying,
    create_time timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updater character varying(64) DEFAULT ''::character varying,
    update_time timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    deleted smallint DEFAULT 0 NOT NULL
);


--
-- Name: TABLE infra_job; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.infra_job IS '瀹氭椂浠诲姟琛?;


--
-- Name: COLUMN infra_job.id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.infra_job.id IS '浠诲姟缂栧彿';


--
-- Name: COLUMN infra_job.name; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.infra_job.name IS '浠诲姟鍚嶇О';


--
-- Name: COLUMN infra_job.status; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.infra_job.status IS '浠诲姟鐘舵€?;


--
-- Name: COLUMN infra_job.handler_name; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.infra_job.handler_name IS '澶勭悊鍣ㄧ殑鍚嶅瓧';


--
-- Name: COLUMN infra_job.handler_param; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.infra_job.handler_param IS '澶勭悊鍣ㄧ殑鍙傛暟';


--
-- Name: COLUMN infra_job.cron_expression; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.infra_job.cron_expression IS 'CRON 琛ㄨ揪寮?;


--
-- Name: COLUMN infra_job.retry_count; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.infra_job.retry_count IS '閲嶈瘯娆℃暟';


--
-- Name: COLUMN infra_job.retry_interval; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.infra_job.retry_interval IS '閲嶈瘯闂撮殧';


--
-- Name: COLUMN infra_job.monitor_timeout; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.infra_job.monitor_timeout IS '鐩戞帶瓒呮椂鏃堕棿';


--
-- Name: COLUMN infra_job.creator; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.infra_job.creator IS '鍒涘缓鑰?;


--
-- Name: COLUMN infra_job.create_time; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.infra_job.create_time IS '鍒涘缓鏃堕棿';


--
-- Name: COLUMN infra_job.updater; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.infra_job.updater IS '鏇存柊鑰?;


--
-- Name: COLUMN infra_job.update_time; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.infra_job.update_time IS '鏇存柊鏃堕棿';


--
-- Name: COLUMN infra_job.deleted; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.infra_job.deleted IS '鏄惁鍒犻櫎';


--
-- Name: infra_job_log; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.infra_job_log (
    id bigint NOT NULL,
    job_id bigint NOT NULL,
    handler_name character varying(64) NOT NULL,
    handler_param character varying(255) DEFAULT NULL::character varying,
    execute_index smallint DEFAULT 1 NOT NULL,
    begin_time timestamp without time zone NOT NULL,
    end_time timestamp without time zone,
    duration integer,
    status smallint NOT NULL,
    result character varying(4000) DEFAULT ''::character varying,
    creator character varying(64) DEFAULT ''::character varying,
    create_time timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updater character varying(64) DEFAULT ''::character varying,
    update_time timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    deleted smallint DEFAULT 0 NOT NULL
);


--
-- Name: TABLE infra_job_log; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.infra_job_log IS '瀹氭椂浠诲姟鏃ュ織琛?;


--
-- Name: COLUMN infra_job_log.id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.infra_job_log.id IS '鏃ュ織缂栧彿';


--
-- Name: COLUMN infra_job_log.job_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.infra_job_log.job_id IS '浠诲姟缂栧彿';


--
-- Name: COLUMN infra_job_log.handler_name; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.infra_job_log.handler_name IS '澶勭悊鍣ㄧ殑鍚嶅瓧';


--
-- Name: COLUMN infra_job_log.handler_param; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.infra_job_log.handler_param IS '澶勭悊鍣ㄧ殑鍙傛暟';


--
-- Name: COLUMN infra_job_log.execute_index; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.infra_job_log.execute_index IS '绗嚑娆℃墽琛?;


--
-- Name: COLUMN infra_job_log.begin_time; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.infra_job_log.begin_time IS '寮€濮嬫墽琛屾椂闂?;


--
-- Name: COLUMN infra_job_log.end_time; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.infra_job_log.end_time IS '缁撴潫鎵ц鏃堕棿';


--
-- Name: COLUMN infra_job_log.duration; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.infra_job_log.duration IS '鎵ц鏃堕暱';


--
-- Name: COLUMN infra_job_log.status; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.infra_job_log.status IS '浠诲姟鐘舵€?;


--
-- Name: COLUMN infra_job_log.result; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.infra_job_log.result IS '缁撴灉鏁版嵁';


--
-- Name: COLUMN infra_job_log.creator; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.infra_job_log.creator IS '鍒涘缓鑰?;


--
-- Name: COLUMN infra_job_log.create_time; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.infra_job_log.create_time IS '鍒涘缓鏃堕棿';


--
-- Name: COLUMN infra_job_log.updater; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.infra_job_log.updater IS '鏇存柊鑰?;


--
-- Name: COLUMN infra_job_log.update_time; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.infra_job_log.update_time IS '鏇存柊鏃堕棿';


--
-- Name: COLUMN infra_job_log.deleted; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.infra_job_log.deleted IS '鏄惁鍒犻櫎';


--
-- Name: infra_job_log_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.infra_job_log_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: infra_job_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.infra_job_seq
    START WITH 41
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: system_dept; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.system_dept (
    id bigint NOT NULL,
    name character varying(30) DEFAULT ''::character varying NOT NULL,
    parent_id bigint DEFAULT 0 NOT NULL,
    sort integer DEFAULT 0 NOT NULL,
    leader_user_id bigint,
    phone character varying(11) DEFAULT NULL::character varying,
    email character varying(50) DEFAULT NULL::character varying,
    status smallint NOT NULL,
    creator character varying(64) DEFAULT ''::character varying,
    create_time timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updater character varying(64) DEFAULT ''::character varying,
    update_time timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    deleted smallint DEFAULT 0 NOT NULL
);


--
-- Name: TABLE system_dept; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.system_dept IS '閮ㄩ棬琛?;


--
-- Name: COLUMN system_dept.id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.system_dept.id IS '閮ㄩ棬id';


--
-- Name: COLUMN system_dept.name; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.system_dept.name IS '閮ㄩ棬鍚嶇О';


--
-- Name: COLUMN system_dept.parent_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.system_dept.parent_id IS '鐖堕儴闂╥d';


--
-- Name: COLUMN system_dept.sort; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.system_dept.sort IS '鏄剧ず椤哄簭';


--
-- Name: COLUMN system_dept.leader_user_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.system_dept.leader_user_id IS '璐熻矗浜?;


--
-- Name: COLUMN system_dept.phone; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.system_dept.phone IS '鑱旂郴鐢佃瘽';


--
-- Name: COLUMN system_dept.email; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.system_dept.email IS '閭';


--
-- Name: COLUMN system_dept.status; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.system_dept.status IS '閮ㄩ棬鐘舵€侊紙0姝ｅ父 1鍋滅敤锛?;


--
-- Name: COLUMN system_dept.creator; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.system_dept.creator IS '鍒涘缓鑰?;


--
-- Name: COLUMN system_dept.create_time; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.system_dept.create_time IS '鍒涘缓鏃堕棿';


--
-- Name: COLUMN system_dept.updater; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.system_dept.updater IS '鏇存柊鑰?;


--
-- Name: COLUMN system_dept.update_time; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.system_dept.update_time IS '鏇存柊鏃堕棿';


--
-- Name: COLUMN system_dept.deleted; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.system_dept.deleted IS '鏄惁鍒犻櫎';



--
-- Name: system_dept_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.system_dept_seq
    START WITH 118
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: system_dict_data; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.system_dict_data (
    id bigint NOT NULL,
    sort integer DEFAULT 0 NOT NULL,
    label character varying(100) DEFAULT ''::character varying NOT NULL,
    value character varying(100) DEFAULT ''::character varying NOT NULL,
    dict_type character varying(100) DEFAULT ''::character varying NOT NULL,
    status smallint DEFAULT 0 NOT NULL,
    color_type character varying(100) DEFAULT ''::character varying,
    css_class character varying(100) DEFAULT ''::character varying,
    remark character varying(500) DEFAULT NULL::character varying,
    creator character varying(64) DEFAULT ''::character varying,
    create_time timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updater character varying(64) DEFAULT ''::character varying,
    update_time timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    deleted smallint DEFAULT 0 NOT NULL
);


--
-- Name: TABLE system_dict_data; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.system_dict_data IS '瀛楀吀鏁版嵁琛?;


--
-- Name: COLUMN system_dict_data.id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.system_dict_data.id IS '瀛楀吀缂栫爜';


--
-- Name: COLUMN system_dict_data.sort; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.system_dict_data.sort IS '瀛楀吀鎺掑簭';


--
-- Name: COLUMN system_dict_data.label; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.system_dict_data.label IS '瀛楀吀鏍囩';


--
-- Name: COLUMN system_dict_data.value; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.system_dict_data.value IS '瀛楀吀閿€?;


--
-- Name: COLUMN system_dict_data.dict_type; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.system_dict_data.dict_type IS '瀛楀吀绫诲瀷';


--
-- Name: COLUMN system_dict_data.status; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.system_dict_data.status IS '鐘舵€侊紙0姝ｅ父 1鍋滅敤锛?;


--
-- Name: COLUMN system_dict_data.color_type; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.system_dict_data.color_type IS '棰滆壊绫诲瀷';


--
-- Name: COLUMN system_dict_data.css_class; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.system_dict_data.css_class IS 'css 鏍峰紡';


--
-- Name: COLUMN system_dict_data.remark; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.system_dict_data.remark IS '澶囨敞';


--
-- Name: COLUMN system_dict_data.creator; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.system_dict_data.creator IS '鍒涘缓鑰?;


--
-- Name: COLUMN system_dict_data.create_time; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.system_dict_data.create_time IS '鍒涘缓鏃堕棿';


--
-- Name: COLUMN system_dict_data.updater; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.system_dict_data.updater IS '鏇存柊鑰?;


--
-- Name: COLUMN system_dict_data.update_time; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.system_dict_data.update_time IS '鏇存柊鏃堕棿';


--
-- Name: COLUMN system_dict_data.deleted; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.system_dict_data.deleted IS '鏄惁鍒犻櫎';


--
-- Name: system_dict_data_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.system_dict_data_seq
    START WITH 3449
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: system_dict_type; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.system_dict_type (
    id bigint NOT NULL,
    name character varying(100) DEFAULT ''::character varying NOT NULL,
    type character varying(100) DEFAULT ''::character varying NOT NULL,
    status smallint DEFAULT 0 NOT NULL,
    remark character varying(500) DEFAULT NULL::character varying,
    creator character varying(64) DEFAULT ''::character varying,
    create_time timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updater character varying(64) DEFAULT ''::character varying,
    update_time timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    deleted smallint DEFAULT 0 NOT NULL,
    deleted_time timestamp without time zone
);


--
-- Name: TABLE system_dict_type; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.system_dict_type IS '瀛楀吀绫诲瀷琛?;


--
-- Name: COLUMN system_dict_type.id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.system_dict_type.id IS '瀛楀吀涓婚敭';


--
-- Name: COLUMN system_dict_type.name; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.system_dict_type.name IS '瀛楀吀鍚嶇О';


--
-- Name: COLUMN system_dict_type.type; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.system_dict_type.type IS '瀛楀吀绫诲瀷';


--
-- Name: COLUMN system_dict_type.status; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.system_dict_type.status IS '鐘舵€侊紙0姝ｅ父 1鍋滅敤锛?;


--
-- Name: COLUMN system_dict_type.remark; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.system_dict_type.remark IS '澶囨敞';


--
-- Name: COLUMN system_dict_type.creator; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.system_dict_type.creator IS '鍒涘缓鑰?;


--
-- Name: COLUMN system_dict_type.create_time; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.system_dict_type.create_time IS '鍒涘缓鏃堕棿';


--
-- Name: COLUMN system_dict_type.updater; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.system_dict_type.updater IS '鏇存柊鑰?;


--
-- Name: COLUMN system_dict_type.update_time; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.system_dict_type.update_time IS '鏇存柊鏃堕棿';


--
-- Name: COLUMN system_dict_type.deleted; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.system_dict_type.deleted IS '鏄惁鍒犻櫎';


--
-- Name: COLUMN system_dict_type.deleted_time; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.system_dict_type.deleted_time IS '鍒犻櫎鏃堕棿';


--
-- Name: system_dict_type_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.system_dict_type_seq
    START WITH 2139
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: system_login_log; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.system_login_log (
    id bigint NOT NULL,
    log_type bigint NOT NULL,
    trace_id character varying(64) DEFAULT ''::character varying NOT NULL,
    user_id bigint DEFAULT 0 NOT NULL,
    user_type smallint DEFAULT 0 NOT NULL,
    username character varying(50) DEFAULT ''::character varying NOT NULL,
    result smallint NOT NULL,
    user_ip character varying(50) NOT NULL,
    user_agent character varying(512) NOT NULL,
    creator character varying(64) DEFAULT ''::character varying,
    create_time timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updater character varying(64) DEFAULT ''::character varying,
    update_time timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    deleted smallint DEFAULT 0 NOT NULL
);


--
-- Name: TABLE system_login_log; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.system_login_log IS '绯荤粺璁块棶璁板綍';


--
-- Name: COLUMN system_login_log.id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.system_login_log.id IS '璁块棶ID';


--
-- Name: COLUMN system_login_log.log_type; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.system_login_log.log_type IS '鏃ュ織绫诲瀷';


--
-- Name: COLUMN system_login_log.trace_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.system_login_log.trace_id IS '閾捐矾杩借釜缂栧彿';


--
-- Name: COLUMN system_login_log.user_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.system_login_log.user_id IS '鐢ㄦ埛缂栧彿';


--
-- Name: COLUMN system_login_log.user_type; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.system_login_log.user_type IS '鐢ㄦ埛绫诲瀷';


--
-- Name: COLUMN system_login_log.username; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.system_login_log.username IS '鐢ㄦ埛璐﹀彿';


--
-- Name: COLUMN system_login_log.result; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.system_login_log.result IS '鐧婚檰缁撴灉';


--
-- Name: COLUMN system_login_log.user_ip; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.system_login_log.user_ip IS '鐢ㄦ埛 IP';


--
-- Name: COLUMN system_login_log.user_agent; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.system_login_log.user_agent IS '娴忚鍣?UA';


--
-- Name: COLUMN system_login_log.creator; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.system_login_log.creator IS '鍒涘缓鑰?;


--
-- Name: COLUMN system_login_log.create_time; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.system_login_log.create_time IS '鍒涘缓鏃堕棿';


--
-- Name: COLUMN system_login_log.updater; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.system_login_log.updater IS '鏇存柊鑰?;


--
-- Name: COLUMN system_login_log.update_time; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.system_login_log.update_time IS '鏇存柊鏃堕棿';


--
-- Name: COLUMN system_login_log.deleted; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.system_login_log.deleted IS '鏄惁鍒犻櫎';



--
-- Name: system_login_log_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.system_login_log_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: system_menu; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.system_menu (
    id bigint NOT NULL,
    name character varying(50) NOT NULL,
    permission character varying(100) DEFAULT ''::character varying NOT NULL,
    type smallint NOT NULL,
    sort integer DEFAULT 0 NOT NULL,
    parent_id bigint DEFAULT 0 NOT NULL,
    path character varying(200) DEFAULT ''::character varying,
    icon character varying(100) DEFAULT '#'::character varying,
    component character varying(255) DEFAULT NULL::character varying,
    component_name character varying(255) DEFAULT NULL::character varying,
    status smallint DEFAULT 0 NOT NULL,
    visible boolean DEFAULT true NOT NULL,
    keep_alive boolean DEFAULT true NOT NULL,
    always_show boolean DEFAULT true NOT NULL,
    creator character varying(64) DEFAULT ''::character varying,
    create_time timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updater character varying(64) DEFAULT ''::character varying,
    update_time timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    deleted smallint DEFAULT 0 NOT NULL
);


--
-- Name: TABLE system_menu; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.system_menu IS '鑿滃崟鏉冮檺琛?;


--
-- Name: COLUMN system_menu.id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.system_menu.id IS '鑿滃崟ID';


--
-- Name: COLUMN system_menu.name; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.system_menu.name IS '鑿滃崟鍚嶇О';


--
-- Name: COLUMN system_menu.permission; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.system_menu.permission IS '鏉冮檺鏍囪瘑';


--
-- Name: COLUMN system_menu.type; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.system_menu.type IS '鑿滃崟绫诲瀷';


--
-- Name: COLUMN system_menu.sort; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.system_menu.sort IS '鏄剧ず椤哄簭';


--
-- Name: COLUMN system_menu.parent_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.system_menu.parent_id IS '鐖惰彍鍗旾D';


--
-- Name: COLUMN system_menu.path; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.system_menu.path IS '璺敱鍦板潃';


--
-- Name: COLUMN system_menu.icon; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.system_menu.icon IS '鑿滃崟鍥炬爣';


--
-- Name: COLUMN system_menu.component; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.system_menu.component IS '缁勪欢璺緞';


--
-- Name: COLUMN system_menu.component_name; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.system_menu.component_name IS '缁勪欢鍚?;


--
-- Name: COLUMN system_menu.status; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.system_menu.status IS '鑿滃崟鐘舵€?;


--
-- Name: COLUMN system_menu.visible; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.system_menu.visible IS '鏄惁鍙';


--
-- Name: COLUMN system_menu.keep_alive; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.system_menu.keep_alive IS '鏄惁缂撳瓨';


--
-- Name: COLUMN system_menu.always_show; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.system_menu.always_show IS '鏄惁鎬绘槸鏄剧ず';


--
-- Name: COLUMN system_menu.creator; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.system_menu.creator IS '鍒涘缓鑰?;


--
-- Name: COLUMN system_menu.create_time; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.system_menu.create_time IS '鍒涘缓鏃堕棿';


--
-- Name: COLUMN system_menu.updater; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.system_menu.updater IS '鏇存柊鑰?;


--
-- Name: COLUMN system_menu.update_time; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.system_menu.update_time IS '鏇存柊鏃堕棿';


--
-- Name: COLUMN system_menu.deleted; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.system_menu.deleted IS '鏄惁鍒犻櫎';


--
-- Name: system_menu_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.system_menu_seq
    START WITH 5986
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;



--
-- Name: system_oauth2_access_token; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.system_oauth2_access_token (
    id bigint NOT NULL,
    access_token character varying(255) NOT NULL,
    refresh_token character varying(255) NOT NULL,
    user_id bigint NOT NULL,
    user_type smallint NOT NULL,
    user_info character varying(2000) DEFAULT '{}'::character varying NOT NULL,
    client_id character varying(255) NOT NULL,
    scopes character varying(1000) DEFAULT '[]'::character varying NOT NULL,
    expires_time timestamp without time zone NOT NULL,
    creator character varying(64) DEFAULT ''::character varying,
    create_time timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updater character varying(64) DEFAULT ''::character varying,
    update_time timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    deleted smallint DEFAULT 0 NOT NULL
);


--
-- Name: TABLE system_oauth2_access_token; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.system_oauth2_access_token IS 'OAuth2 access token table';


--
-- Name: system_oauth2_access_token_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.system_oauth2_access_token_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;



--
-- Name: system_oauth2_refresh_token; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.system_oauth2_refresh_token (
    id bigint NOT NULL,
    refresh_token character varying(255) NOT NULL,
    user_id bigint NOT NULL,
    user_type smallint NOT NULL,
    client_id character varying(255) NOT NULL,
    scopes character varying(1000) DEFAULT '[]'::character varying NOT NULL,
    expires_time timestamp without time zone NOT NULL,
    creator character varying(64) DEFAULT ''::character varying,
    create_time timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updater character varying(64) DEFAULT ''::character varying,
    update_time timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    deleted smallint DEFAULT 0 NOT NULL
);


--
-- Name: TABLE system_oauth2_refresh_token; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.system_oauth2_refresh_token IS 'OAuth2 refresh token table';


--
-- Name: system_operate_log; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.system_operate_log (
    id bigint NOT NULL,
    trace_id character varying(64) DEFAULT ''::character varying NOT NULL,
    user_id bigint NOT NULL,
    user_type smallint DEFAULT 0 NOT NULL,
    type character varying(50) NOT NULL,
    sub_type character varying(50) NOT NULL,
    biz_id bigint NOT NULL,
    action character varying(2000) DEFAULT ''::character varying NOT NULL,
    success boolean DEFAULT true NOT NULL,
    extra character varying(2000) DEFAULT ''::character varying NOT NULL,
    request_method character varying(16) DEFAULT ''::character varying,
    request_url character varying(255) DEFAULT ''::character varying,
    user_ip character varying(50) DEFAULT NULL::character varying,
    user_agent character varying(512) DEFAULT NULL::character varying,
    creator character varying(64) DEFAULT ''::character varying,
    create_time timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updater character varying(64) DEFAULT ''::character varying,
    update_time timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    deleted smallint DEFAULT 0 NOT NULL
);


--
-- Name: TABLE system_operate_log; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.system_operate_log IS '鎿嶄綔鏃ュ織璁板綍 V2 鐗堟湰';


--
-- Name: COLUMN system_operate_log.id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.system_operate_log.id IS '鏃ュ織涓婚敭';


--
-- Name: COLUMN system_operate_log.trace_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.system_operate_log.trace_id IS '閾捐矾杩借釜缂栧彿';


--
-- Name: COLUMN system_operate_log.user_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.system_operate_log.user_id IS '鐢ㄦ埛缂栧彿';


--
-- Name: COLUMN system_operate_log.user_type; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.system_operate_log.user_type IS '鐢ㄦ埛绫诲瀷';


--
-- Name: COLUMN system_operate_log.type; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.system_operate_log.type IS '鎿嶄綔妯″潡绫诲瀷';


--
-- Name: COLUMN system_operate_log.sub_type; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.system_operate_log.sub_type IS '鎿嶄綔鍚?;


--
-- Name: COLUMN system_operate_log.biz_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.system_operate_log.biz_id IS '鎿嶄綔鏁版嵁妯″潡缂栧彿';


--
-- Name: COLUMN system_operate_log.action; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.system_operate_log.action IS '鎿嶄綔鍐呭';


--
-- Name: COLUMN system_operate_log.success; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.system_operate_log.success IS '鎿嶄綔缁撴灉';


--
-- Name: COLUMN system_operate_log.extra; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.system_operate_log.extra IS '鎷撳睍瀛楁';


--
-- Name: COLUMN system_operate_log.request_method; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.system_operate_log.request_method IS '璇锋眰鏂规硶鍚?;


--
-- Name: COLUMN system_operate_log.request_url; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.system_operate_log.request_url IS '璇锋眰鍦板潃';


--
-- Name: COLUMN system_operate_log.user_ip; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.system_operate_log.user_ip IS '鐢ㄦ埛 IP';


--
-- Name: COLUMN system_operate_log.user_agent; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.system_operate_log.user_agent IS '娴忚鍣?UA';


--
-- Name: COLUMN system_operate_log.creator; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.system_operate_log.creator IS '鍒涘缓鑰?;


--
-- Name: COLUMN system_operate_log.create_time; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.system_operate_log.create_time IS '鍒涘缓鏃堕棿';


--
-- Name: COLUMN system_operate_log.updater; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.system_operate_log.updater IS '鏇存柊鑰?;


--
-- Name: COLUMN system_operate_log.update_time; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.system_operate_log.update_time IS '鏇存柊鏃堕棿';


--
-- Name: COLUMN system_operate_log.deleted; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.system_operate_log.deleted IS '鏄惁鍒犻櫎';



--
-- Name: system_operate_log_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.system_operate_log_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: system_post; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.system_post (
    id bigint NOT NULL,
    code character varying(64) NOT NULL,
    name character varying(50) NOT NULL,
    sort integer NOT NULL,
    status smallint NOT NULL,
    remark character varying(500) DEFAULT NULL::character varying,
    creator character varying(64) DEFAULT ''::character varying,
    create_time timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updater character varying(64) DEFAULT ''::character varying,
    update_time timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    deleted smallint DEFAULT 0 NOT NULL
);


--
-- Name: TABLE system_post; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.system_post IS '宀椾綅淇℃伅琛?;


--
-- Name: COLUMN system_post.id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.system_post.id IS '宀椾綅ID';


--
-- Name: COLUMN system_post.code; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.system_post.code IS '宀椾綅缂栫爜';


--
-- Name: COLUMN system_post.name; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.system_post.name IS '宀椾綅鍚嶇О';


--
-- Name: COLUMN system_post.sort; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.system_post.sort IS '鏄剧ず椤哄簭';


--
-- Name: COLUMN system_post.status; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.system_post.status IS '鐘舵€侊紙0姝ｅ父 1鍋滅敤锛?;


--
-- Name: COLUMN system_post.remark; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.system_post.remark IS '澶囨敞';


--
-- Name: COLUMN system_post.creator; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.system_post.creator IS '鍒涘缓鑰?;


--
-- Name: COLUMN system_post.create_time; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.system_post.create_time IS '鍒涘缓鏃堕棿';


--
-- Name: COLUMN system_post.updater; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.system_post.updater IS '鏇存柊鑰?;


--
-- Name: COLUMN system_post.update_time; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.system_post.update_time IS '鏇存柊鏃堕棿';


--
-- Name: COLUMN system_post.deleted; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.system_post.deleted IS '鏄惁鍒犻櫎';



--
-- Name: system_post_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.system_post_seq
    START WITH 8
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: system_role; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.system_role (
    id bigint NOT NULL,
    name character varying(30) NOT NULL,
    code character varying(100) NOT NULL,
    sort integer NOT NULL,
    data_scope smallint DEFAULT 1 NOT NULL,
    data_scope_dept_ids character varying(500) DEFAULT ''::character varying NOT NULL,
    status smallint NOT NULL,
    type smallint NOT NULL,
    remark character varying(500) DEFAULT NULL::character varying,
    creator character varying(64) DEFAULT ''::character varying,
    create_time timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updater character varying(64) DEFAULT ''::character varying,
    update_time timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    deleted smallint DEFAULT 0 NOT NULL
);


--
-- Name: TABLE system_role; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.system_role IS '瑙掕壊淇℃伅琛?;


--
-- Name: COLUMN system_role.id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.system_role.id IS '瑙掕壊ID';


--
-- Name: COLUMN system_role.name; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.system_role.name IS '瑙掕壊鍚嶇О';


--
-- Name: COLUMN system_role.code; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.system_role.code IS '瑙掕壊鏉冮檺瀛楃涓?;


--
-- Name: COLUMN system_role.sort; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.system_role.sort IS '鏄剧ず椤哄簭';


--
-- Name: COLUMN system_role.data_scope; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.system_role.data_scope IS '鏁版嵁鑼冨洿锛?锛氬叏閮ㄦ暟鎹潈闄?2锛氳嚜瀹氭暟鎹潈闄?3锛氭湰閮ㄩ棬鏁版嵁鏉冮檺 4锛氭湰閮ㄩ棬鍙婁互涓嬫暟鎹潈闄愶級';


--
-- Name: COLUMN system_role.data_scope_dept_ids; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.system_role.data_scope_dept_ids IS '鏁版嵁鑼冨洿(鎸囧畾閮ㄩ棬鏁扮粍)';


--
-- Name: COLUMN system_role.status; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.system_role.status IS '瑙掕壊鐘舵€侊紙0姝ｅ父 1鍋滅敤锛?;


--
-- Name: COLUMN system_role.type; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.system_role.type IS '瑙掕壊绫诲瀷';


--
-- Name: COLUMN system_role.remark; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.system_role.remark IS '澶囨敞';


--
-- Name: COLUMN system_role.creator; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.system_role.creator IS '鍒涘缓鑰?;


--
-- Name: COLUMN system_role.create_time; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.system_role.create_time IS '鍒涘缓鏃堕棿';


--
-- Name: COLUMN system_role.updater; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.system_role.updater IS '鏇存柊鑰?;


--
-- Name: COLUMN system_role.update_time; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.system_role.update_time IS '鏇存柊鏃堕棿';


--
-- Name: COLUMN system_role.deleted; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.system_role.deleted IS '鏄惁鍒犻櫎';



--
-- Name: system_role_menu; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.system_role_menu (
    id bigint NOT NULL,
    role_id bigint NOT NULL,
    menu_id bigint NOT NULL,
    creator character varying(64) DEFAULT ''::character varying,
    create_time timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updater character varying(64) DEFAULT ''::character varying,
    update_time timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    deleted smallint DEFAULT 0 NOT NULL
);


--
-- Name: TABLE system_role_menu; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.system_role_menu IS '瑙掕壊鍜岃彍鍗曞叧鑱旇〃';


--
-- Name: COLUMN system_role_menu.id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.system_role_menu.id IS '鑷缂栧彿';


--
-- Name: COLUMN system_role_menu.role_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.system_role_menu.role_id IS '瑙掕壊ID';


--
-- Name: COLUMN system_role_menu.menu_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.system_role_menu.menu_id IS '鑿滃崟ID';


--
-- Name: COLUMN system_role_menu.creator; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.system_role_menu.creator IS '鍒涘缓鑰?;


--
-- Name: COLUMN system_role_menu.create_time; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.system_role_menu.create_time IS '鍒涘缓鏃堕棿';


--
-- Name: COLUMN system_role_menu.updater; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.system_role_menu.updater IS '鏇存柊鑰?;


--
-- Name: COLUMN system_role_menu.update_time; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.system_role_menu.update_time IS '鏇存柊鏃堕棿';


--
-- Name: COLUMN system_role_menu.deleted; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.system_role_menu.deleted IS '鏄惁鍒犻櫎';



--
-- Name: system_role_menu_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.system_role_menu_seq
    START WITH 6365
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: system_role_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.system_role_seq
    START WITH 156
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: system_user_post; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.system_user_post (
    id bigint NOT NULL,
    user_id bigint DEFAULT 0 NOT NULL,
    post_id bigint DEFAULT 0 NOT NULL,
    creator character varying(64) DEFAULT ''::character varying,
    create_time timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updater character varying(64) DEFAULT ''::character varying,
    update_time timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    deleted smallint DEFAULT 0 NOT NULL
);


--
-- Name: TABLE system_user_post; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.system_user_post IS '鐢ㄦ埛宀椾綅琛?;


--
-- Name: COLUMN system_user_post.id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.system_user_post.id IS 'id';


--
-- Name: COLUMN system_user_post.user_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.system_user_post.user_id IS '鐢ㄦ埛ID';


--
-- Name: COLUMN system_user_post.post_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.system_user_post.post_id IS '宀椾綅ID';


--
-- Name: COLUMN system_user_post.creator; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.system_user_post.creator IS '鍒涘缓鑰?;


--
-- Name: COLUMN system_user_post.create_time; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.system_user_post.create_time IS '鍒涘缓鏃堕棿';


--
-- Name: COLUMN system_user_post.updater; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.system_user_post.updater IS '鏇存柊鑰?;


--
-- Name: COLUMN system_user_post.update_time; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.system_user_post.update_time IS '鏇存柊鏃堕棿';


--
-- Name: COLUMN system_user_post.deleted; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.system_user_post.deleted IS '鏄惁鍒犻櫎';



--
-- Name: system_user_post_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.system_user_post_seq
    START WITH 130
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: system_user_role; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.system_user_role (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    role_id bigint NOT NULL,
    creator character varying(64) DEFAULT ''::character varying,
    create_time timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updater character varying(64) DEFAULT ''::character varying,
    update_time timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    deleted smallint DEFAULT 0 NOT NULL
);


--
-- Name: TABLE system_user_role; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.system_user_role IS '鐢ㄦ埛鍜岃鑹插叧鑱旇〃';


--
-- Name: COLUMN system_user_role.id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.system_user_role.id IS '鑷缂栧彿';


--
-- Name: COLUMN system_user_role.user_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.system_user_role.user_id IS '鐢ㄦ埛ID';


--
-- Name: COLUMN system_user_role.role_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.system_user_role.role_id IS '瑙掕壊ID';


--
-- Name: COLUMN system_user_role.creator; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.system_user_role.creator IS '鍒涘缓鑰?;


--
-- Name: COLUMN system_user_role.create_time; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.system_user_role.create_time IS '鍒涘缓鏃堕棿';


--
-- Name: COLUMN system_user_role.updater; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.system_user_role.updater IS '鏇存柊鑰?;


--
-- Name: COLUMN system_user_role.update_time; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.system_user_role.update_time IS '鏇存柊鏃堕棿';


--
-- Name: COLUMN system_user_role.deleted; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.system_user_role.deleted IS '鏄惁鍒犻櫎';



--
-- Name: system_user_role_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.system_user_role_seq
    START WITH 55
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: system_users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.system_users (
    id bigint NOT NULL,
    username character varying(30) NOT NULL,
    password character varying(100) DEFAULT ''::character varying NOT NULL,
    nickname character varying(30) NOT NULL,
    remark character varying(500) DEFAULT NULL::character varying,
    dept_id bigint,
    post_ids character varying(255) DEFAULT NULL::character varying,
    email character varying(50) DEFAULT ''::character varying,
    mobile character varying(11) DEFAULT ''::character varying,
    sex smallint DEFAULT 0,
    avatar character varying(512) DEFAULT ''::character varying,
    status smallint DEFAULT 0 NOT NULL,
    login_ip character varying(50) DEFAULT ''::character varying,
    login_date timestamp without time zone,
    creator character varying(64) DEFAULT ''::character varying,
    create_time timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updater character varying(64) DEFAULT ''::character varying,
    update_time timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    deleted smallint DEFAULT 0 NOT NULL
);


--
-- Name: TABLE system_users; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.system_users IS '鐢ㄦ埛淇℃伅琛?;


--
-- Name: COLUMN system_users.id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.system_users.id IS '鐢ㄦ埛ID';


--
-- Name: COLUMN system_users.username; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.system_users.username IS '鐢ㄦ埛璐﹀彿';


--
-- Name: COLUMN system_users.password; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.system_users.password IS '瀵嗙爜';


--
-- Name: COLUMN system_users.nickname; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.system_users.nickname IS '鐢ㄦ埛鏄电О';


--
-- Name: COLUMN system_users.remark; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.system_users.remark IS '澶囨敞';


--
-- Name: COLUMN system_users.dept_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.system_users.dept_id IS '閮ㄩ棬ID';


--
-- Name: COLUMN system_users.post_ids; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.system_users.post_ids IS '宀椾綅缂栧彿鏁扮粍';


--
-- Name: COLUMN system_users.email; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.system_users.email IS '鐢ㄦ埛閭';


--
-- Name: COLUMN system_users.mobile; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.system_users.mobile IS '鎵嬫満鍙风爜';


--
-- Name: COLUMN system_users.sex; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.system_users.sex IS '鐢ㄦ埛鎬у埆';


--
-- Name: COLUMN system_users.avatar; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.system_users.avatar IS '澶村儚鍦板潃';


--
-- Name: COLUMN system_users.status; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.system_users.status IS '甯愬彿鐘舵€侊紙0姝ｅ父 1鍋滅敤锛?;


--
-- Name: COLUMN system_users.login_ip; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.system_users.login_ip IS '鏈€鍚庣櫥褰旾P';


--
-- Name: COLUMN system_users.login_date; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.system_users.login_date IS '鏈€鍚庣櫥褰曟椂闂?;


--
-- Name: COLUMN system_users.creator; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.system_users.creator IS '鍒涘缓鑰?;


--
-- Name: COLUMN system_users.create_time; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.system_users.create_time IS '鍒涘缓鏃堕棿';


--
-- Name: COLUMN system_users.updater; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.system_users.updater IS '鏇存柊鑰?;


--
-- Name: COLUMN system_users.update_time; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.system_users.update_time IS '鏇存柊鏃堕棿';


--
-- Name: COLUMN system_users.deleted; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.system_users.deleted IS '鏄惁鍒犻櫎';



--
-- Name: system_users_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.system_users_seq
    START WITH 145
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Data for Name: dual; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.dual (id) VALUES (1);


--
-- Data for Name: infra_api_access_log; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: infra_api_error_log; Type: TABLE DATA; Schema: public; Owner: -
--




--
-- Data for Name: infra_job; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.infra_job (id, name, status, handler_name, handler_param, cron_expression, retry_count, retry_interval, monitor_timeout, creator, create_time, updater, update_time, deleted) VALUES (25, '璁块棶鏃ュ織娓呯悊 Job', 2, 'accessLogCleanJob', '', '0 0 0 * * ?', 3, 0, 0, '1', '2023-10-03 10:59:41', '1', '2023-10-03 11:01:10', 0);
INSERT INTO public.infra_job (id, name, status, handler_name, handler_param, cron_expression, retry_count, retry_interval, monitor_timeout, creator, create_time, updater, update_time, deleted) VALUES (26, '閿欒鏃ュ織娓呯悊 Job', 2, 'errorLogCleanJob', '', '0 0 0 * * ?', 3, 0, 0, '1', '2023-10-03 11:00:43', '1', '2023-10-03 11:01:12', 0);
INSERT INTO public.infra_job (id, name, status, handler_name, handler_param, cron_expression, retry_count, retry_interval, monitor_timeout, creator, create_time, updater, update_time, deleted) VALUES (27, '浠诲姟鏃ュ織娓呯悊 Job', 2, 'jobLogCleanJob', '', '0 0 0 * * ?', 3, 0, 0, '1', '2023-10-03 11:01:33', '1', '2024-09-12 13:40:34', 0);


--
-- Data for Name: infra_job_log; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: system_dept; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.system_dept (id, name, parent_id, sort, leader_user_id, phone, email, status, creator, create_time, updater, update_time, deleted) VALUES (100, '鑺嬮亾婧愮爜', 0, 0, 1, '15888888888', 'ry@qq.com', 0, 'admin', '2021-01-05 17:03:47', '1', '2026-01-04 18:01:12', 0);
INSERT INTO public.system_dept (id, name, parent_id, sort, leader_user_id, phone, email, status, creator, create_time, updater, update_time, deleted) VALUES (101, '娣卞湷鎬诲叕鍙?, 100, 1, 104, '15888888888', 'ry@qq.com', 0, 'admin', '2021-01-05 17:03:47', '1', '2025-03-29 15:49:55', 0);
INSERT INTO public.system_dept (id, name, parent_id, sort, leader_user_id, phone, email, status, creator, create_time, updater, update_time, deleted) VALUES (102, '闀挎矙鍒嗗叕鍙?, 100, 2, NULL, '15888888888', 'ry@qq.com', 0, 'admin', '2021-01-05 17:03:47', '', '2021-12-15 05:01:40', 0);
INSERT INTO public.system_dept (id, name, parent_id, sort, leader_user_id, phone, email, status, creator, create_time, updater, update_time, deleted) VALUES (103, '鐮斿彂閮ㄩ棬', 101, 1, 104, '15888888888', 'ry@qq.com', 0, 'admin', '2021-01-05 17:03:47', '1', '2026-01-04 18:01:24', 0);
INSERT INTO public.system_dept (id, name, parent_id, sort, leader_user_id, phone, email, status, creator, create_time, updater, update_time, deleted) VALUES (104, '甯傚満閮ㄩ棬', 101, 2, NULL, '15888888888', 'ry@qq.com', 0, 'admin', '2021-01-05 17:03:47', '', '2021-12-15 05:01:38', 0);
INSERT INTO public.system_dept (id, name, parent_id, sort, leader_user_id, phone, email, status, creator, create_time, updater, update_time, deleted) VALUES (105, '娴嬭瘯閮ㄩ棬', 101, 3, NULL, '15888888888', 'ry@qq.com', 0, 'admin', '2021-01-05 17:03:47', '1', '2022-05-16 20:25:15', 0);
INSERT INTO public.system_dept (id, name, parent_id, sort, leader_user_id, phone, email, status, creator, create_time, updater, update_time, deleted) VALUES (106, '璐㈠姟閮ㄩ棬', 101, 4, 103, '15888888888', 'ry@qq.com', 0, 'admin', '2021-01-05 17:03:47', '103', '2022-01-15 21:32:22', 0);
INSERT INTO public.system_dept (id, name, parent_id, sort, leader_user_id, phone, email, status, creator, create_time, updater, update_time, deleted) VALUES (107, '杩愮淮閮ㄩ棬', 101, 5, 1, '15888888888', 'ry@qq.com', 0, 'admin', '2021-01-05 17:03:47', '1', '2023-12-02 09:28:22', 0);
INSERT INTO public.system_dept (id, name, parent_id, sort, leader_user_id, phone, email, status, creator, create_time, updater, update_time, deleted) VALUES (108, '甯傚満閮ㄩ棬', 102, 1, NULL, '15888888888', 'ry@qq.com', 0, 'admin', '2021-01-05 17:03:47', '1', '2022-02-16 08:35:45', 0);
INSERT INTO public.system_dept (id, name, parent_id, sort, leader_user_id, phone, email, status, creator, create_time, updater, update_time, deleted) VALUES (109, '璐㈠姟閮ㄩ棬', 102, 2, NULL, '15888888888', 'ry@qq.com', 0, 'admin', '2021-01-05 17:03:47', '', '2021-12-15 05:01:29', 0);
INSERT INTO public.system_dept (id, name, parent_id, sort, leader_user_id, phone, email, status, creator, create_time, updater, update_time, deleted) VALUES (110, '鏂伴儴闂?, 0, 1, NULL, NULL, NULL, 0, '110', '2022-02-23 20:46:30', '110', '2022-02-23 20:46:30', 0);
INSERT INTO public.system_dept (id, name, parent_id, sort, leader_user_id, phone, email, status, creator, create_time, updater, update_time, deleted) VALUES (111, '椤剁骇閮ㄩ棬', 0, 1, NULL, NULL, NULL, 0, '113', '2022-03-07 21:44:50', '113', '2022-03-07 21:44:50', 0);
INSERT INTO public.system_dept (id, name, parent_id, sort, leader_user_id, phone, email, status, creator, create_time, updater, update_time, deleted) VALUES (112, '浜у搧閮ㄩ棬', 101, 100, 1, NULL, NULL, 1, '1', '2023-12-02 09:45:13', '1', '2023-12-02 09:45:31', 0);
INSERT INTO public.system_dept (id, name, parent_id, sort, leader_user_id, phone, email, status, creator, create_time, updater, update_time, deleted) VALUES (113, '鏀寔閮ㄩ棬', 102, 3, 104, NULL, NULL, 1, '1', '2023-12-02 09:47:38', '1', '2025-03-29 15:00:56', 0);
INSERT INTO public.system_dept (id, name, parent_id, sort, leader_user_id, phone, email, status, creator, create_time, updater, update_time, deleted) VALUES (116, '鏌愪釜瀛愰儴闂?, 0, 1, NULL, NULL, NULL, 0, '1', '2025-12-08 14:51:12', '1', '2025-12-08 14:51:12', 0);
INSERT INTO public.system_dept (id, name, parent_id, sort, leader_user_id, phone, email, status, creator, create_time, updater, update_time, deleted) VALUES (117, '鏌愪釜瀛愰儴闂?2', 0, 2, NULL, NULL, NULL, 0, '1', '2025-12-08 14:51:25', '1', '2025-12-08 14:51:25', 0);


--
-- Data for Name: system_dict_data; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.system_dict_data (id, sort, label, value, dict_type, status, color_type, css_class, remark, creator, create_time, updater, update_time, deleted) VALUES (1, 1, '鐢?, '1', 'system_user_sex', 0, 'primary', 'A', '鎬у埆鐢?, 'admin', '2021-01-05 17:03:48', '1', '2025-12-10 13:19:26', 0);
INSERT INTO public.system_dict_data (id, sort, label, value, dict_type, status, color_type, css_class, remark, creator, create_time, updater, update_time, deleted) VALUES (2, 2, '濂?, '2', 'system_user_sex', 0, 'success', '', '鎬у埆濂?, 'admin', '2021-01-05 17:03:48', '1', '2023-11-15 23:30:37', 0);
INSERT INTO public.system_dict_data (id, sort, label, value, dict_type, status, color_type, css_class, remark, creator, create_time, updater, update_time, deleted) VALUES (8, 1, '姝ｅ父', '1', 'infra_job_status', 0, 'success', '', '姝ｅ父鐘舵€?, 'admin', '2021-01-05 17:03:48', '1', '2022-02-16 19:33:38', 0);
INSERT INTO public.system_dict_data (id, sort, label, value, dict_type, status, color_type, css_class, remark, creator, create_time, updater, update_time, deleted) VALUES (9, 2, '鏆傚仠', '2', 'infra_job_status', 0, 'danger', '', '鍋滅敤鐘舵€?, 'admin', '2021-01-05 17:03:48', '1', '2022-02-16 19:33:45', 0);
INSERT INTO public.system_dict_data (id, sort, label, value, dict_type, status, color_type, css_class, remark, creator, create_time, updater, update_time, deleted) VALUES (16, 0, '鍏跺畠', '0', 'infra_operate_type', 0, 'default', '', '鍏跺畠鎿嶄綔', 'admin', '2021-01-05 17:03:48', '1', '2024-03-14 12:44:19', 0);
INSERT INTO public.system_dict_data (id, sort, label, value, dict_type, status, color_type, css_class, remark, creator, create_time, updater, update_time, deleted) VALUES (17, 1, '鏌ヨ', '1', 'infra_operate_type', 0, 'info', '', '鏌ヨ鎿嶄綔', 'admin', '2021-01-05 17:03:48', '1', '2024-03-14 12:44:20', 0);
INSERT INTO public.system_dict_data (id, sort, label, value, dict_type, status, color_type, css_class, remark, creator, create_time, updater, update_time, deleted) VALUES (18, 2, '鏂板', '2', 'infra_operate_type', 0, 'primary', '', '鏂板鎿嶄綔', 'admin', '2021-01-05 17:03:48', '1', '2024-03-14 12:44:21', 0);
INSERT INTO public.system_dict_data (id, sort, label, value, dict_type, status, color_type, css_class, remark, creator, create_time, updater, update_time, deleted) VALUES (19, 3, '淇敼', '3', 'infra_operate_type', 0, 'warning', '', '淇敼鎿嶄綔', 'admin', '2021-01-05 17:03:48', '1', '2024-03-14 12:44:22', 0);
INSERT INTO public.system_dict_data (id, sort, label, value, dict_type, status, color_type, css_class, remark, creator, create_time, updater, update_time, deleted) VALUES (20, 4, '鍒犻櫎', '4', 'infra_operate_type', 0, 'danger', '', '鍒犻櫎鎿嶄綔', 'admin', '2021-01-05 17:03:48', '1', '2024-03-14 12:44:23', 0);
INSERT INTO public.system_dict_data (id, sort, label, value, dict_type, status, color_type, css_class, remark, creator, create_time, updater, update_time, deleted) VALUES (22, 5, '瀵煎嚭', '5', 'infra_operate_type', 0, 'default', '', '瀵煎嚭鎿嶄綔', 'admin', '2021-01-05 17:03:48', '1', '2024-03-14 12:44:24', 0);
INSERT INTO public.system_dict_data (id, sort, label, value, dict_type, status, color_type, css_class, remark, creator, create_time, updater, update_time, deleted) VALUES (23, 6, '瀵煎叆', '6', 'infra_operate_type', 0, 'default', '', '瀵煎叆鎿嶄綔', 'admin', '2021-01-05 17:03:48', '1', '2024-03-14 12:44:25', 0);
INSERT INTO public.system_dict_data (id, sort, label, value, dict_type, status, color_type, css_class, remark, creator, create_time, updater, update_time, deleted) VALUES (27, 1, '寮€鍚?, '0', 'common_status', 0, 'primary', '', '寮€鍚姸鎬?, 'admin', '2021-01-05 17:03:48', '1', '2022-02-16 08:00:39', 0);
INSERT INTO public.system_dict_data (id, sort, label, value, dict_type, status, color_type, css_class, remark, creator, create_time, updater, update_time, deleted) VALUES (28, 2, '鍏抽棴', '1', 'common_status', 0, 'info', '', '鍏抽棴鐘舵€?, 'admin', '2021-01-05 17:03:48', '1', '2022-02-16 08:00:44', 0);
INSERT INTO public.system_dict_data (id, sort, label, value, dict_type, status, color_type, css_class, remark, creator, create_time, updater, update_time, deleted) VALUES (29, 1, '鐩綍', '1', 'system_menu_type', 0, '', '', '鐩綍', 'admin', '2021-01-05 17:03:48', '', '2022-02-01 16:43:45', 0);
INSERT INTO public.system_dict_data (id, sort, label, value, dict_type, status, color_type, css_class, remark, creator, create_time, updater, update_time, deleted) VALUES (30, 2, '鑿滃崟', '2', 'system_menu_type', 0, '', '', '鑿滃崟', 'admin', '2021-01-05 17:03:48', '', '2022-02-01 16:43:41', 0);
INSERT INTO public.system_dict_data (id, sort, label, value, dict_type, status, color_type, css_class, remark, creator, create_time, updater, update_time, deleted) VALUES (31, 3, '鎸夐挳', '3', 'system_menu_type', 0, '', '', '鎸夐挳', 'admin', '2021-01-05 17:03:48', '', '2022-02-01 16:43:39', 0);
INSERT INTO public.system_dict_data (id, sort, label, value, dict_type, status, color_type, css_class, remark, creator, create_time, updater, update_time, deleted) VALUES (32, 1, '鍐呯疆', '1', 'system_role_type', 0, 'danger', '', '鍐呯疆瑙掕壊', 'admin', '2021-01-05 17:03:48', '1', '2022-02-16 13:02:08', 0);
INSERT INTO public.system_dict_data (id, sort, label, value, dict_type, status, color_type, css_class, remark, creator, create_time, updater, update_time, deleted) VALUES (33, 2, '鑷畾涔?, '2', 'system_role_type', 0, 'primary', '', '鑷畾涔夎鑹?, 'admin', '2021-01-05 17:03:48', '1', '2022-02-16 13:02:12', 0);
INSERT INTO public.system_dict_data (id, sort, label, value, dict_type, status, color_type, css_class, remark, creator, create_time, updater, update_time, deleted) VALUES (34, 1, '鍏ㄩ儴鏁版嵁鏉冮檺', '1', 'system_data_scope', 0, '', '', '鍏ㄩ儴鏁版嵁鏉冮檺', 'admin', '2021-01-05 17:03:48', '', '2022-02-01 16:47:17', 0);
INSERT INTO public.system_dict_data (id, sort, label, value, dict_type, status, color_type, css_class, remark, creator, create_time, updater, update_time, deleted) VALUES (35, 2, '鎸囧畾閮ㄩ棬鏁版嵁鏉冮檺', '2', 'system_data_scope', 0, '', '', '鎸囧畾閮ㄩ棬鏁版嵁鏉冮檺', 'admin', '2021-01-05 17:03:48', '', '2022-02-01 16:47:18', 0);
INSERT INTO public.system_dict_data (id, sort, label, value, dict_type, status, color_type, css_class, remark, creator, create_time, updater, update_time, deleted) VALUES (36, 3, '鏈儴闂ㄦ暟鎹潈闄?, '3', 'system_data_scope', 0, '', '', '鏈儴闂ㄦ暟鎹潈闄?, 'admin', '2021-01-05 17:03:48', '', '2022-02-01 16:47:16', 0);
INSERT INTO public.system_dict_data (id, sort, label, value, dict_type, status, color_type, css_class, remark, creator, create_time, updater, update_time, deleted) VALUES (37, 4, '鏈儴闂ㄥ強浠ヤ笅鏁版嵁鏉冮檺', '4', 'system_data_scope', 0, '', '', '鏈儴闂ㄥ強浠ヤ笅鏁版嵁鏉冮檺', 'admin', '2021-01-05 17:03:48', '', '2022-02-01 16:47:21', 0);
INSERT INTO public.system_dict_data (id, sort, label, value, dict_type, status, color_type, css_class, remark, creator, create_time, updater, update_time, deleted) VALUES (38, 5, '浠呮湰浜烘暟鎹潈闄?, '5', 'system_data_scope', 0, '', '', '浠呮湰浜烘暟鎹潈闄?, 'admin', '2021-01-05 17:03:48', '', '2022-02-01 16:47:23', 0);
INSERT INTO public.system_dict_data (id, sort, label, value, dict_type, status, color_type, css_class, remark, creator, create_time, updater, update_time, deleted) VALUES (39, 0, '鎴愬姛', '0', 'system_login_result', 0, 'success', '', '鐧婚檰缁撴灉 - 鎴愬姛', '', '2021-01-18 06:17:36', '1', '2022-02-16 13:23:49', 0);
INSERT INTO public.system_dict_data (id, sort, label, value, dict_type, status, color_type, css_class, remark, creator, create_time, updater, update_time, deleted) VALUES (40, 10, '璐﹀彿鎴栧瘑鐮佷笉姝ｇ‘', '10', 'system_login_result', 0, 'primary', '', '鐧婚檰缁撴灉 - 璐﹀彿鎴栧瘑鐮佷笉姝ｇ‘', '', '2021-01-18 06:17:54', '1', '2022-02-16 13:24:27', 0);
INSERT INTO public.system_dict_data (id, sort, label, value, dict_type, status, color_type, css_class, remark, creator, create_time, updater, update_time, deleted) VALUES (41, 20, '鐢ㄦ埛琚鐢?, '20', 'system_login_result', 0, 'warning', '', '鐧婚檰缁撴灉 - 鐢ㄦ埛琚鐢?, '', '2021-01-18 06:17:54', '1', '2022-02-16 13:23:57', 0);
INSERT INTO public.system_dict_data (id, sort, label, value, dict_type, status, color_type, css_class, remark, creator, create_time, updater, update_time, deleted) VALUES (42, 30, '楠岃瘉鐮佷笉瀛樺湪', '30', 'system_login_result', 0, 'info', '', '鐧婚檰缁撴灉 - 楠岃瘉鐮佷笉瀛樺湪', '', '2021-01-18 06:17:54', '1', '2022-02-16 13:24:07', 0);
INSERT INTO public.system_dict_data (id, sort, label, value, dict_type, status, color_type, css_class, remark, creator, create_time, updater, update_time, deleted) VALUES (43, 31, '楠岃瘉鐮佷笉姝ｇ‘', '31', 'system_login_result', 0, 'info', '', '鐧婚檰缁撴灉 - 楠岃瘉鐮佷笉姝ｇ‘', '', '2021-01-18 06:17:54', '1', '2022-02-16 13:24:11', 0);
INSERT INTO public.system_dict_data (id, sort, label, value, dict_type, status, color_type, css_class, remark, creator, create_time, updater, update_time, deleted) VALUES (44, 100, '鏈煡寮傚父', '100', 'system_login_result', 0, 'danger', '', '鐧婚檰缁撴灉 - 鏈煡寮傚父', '', '2021-01-18 06:17:54', '1', '2022-02-16 13:24:23', 0);
INSERT INTO public.system_dict_data (id, sort, label, value, dict_type, status, color_type, css_class, remark, creator, create_time, updater, update_time, deleted) VALUES (45, 1, '鏄?, 'true', 'infra_boolean_string', 0, 'danger', '', 'Boolean 鏄惁绫诲瀷 - 鏄?, '', '2021-01-19 03:20:55', '1', '2022-03-15 23:01:45', 0);
INSERT INTO public.system_dict_data (id, sort, label, value, dict_type, status, color_type, css_class, remark, creator, create_time, updater, update_time, deleted) VALUES (46, 1, '鍚?, 'false', 'infra_boolean_string', 0, 'info', '', 'Boolean 鏄惁绫诲瀷 - 鍚?, '', '2021-01-19 03:20:55', '1', '2022-03-15 23:09:45', 0);
INSERT INTO public.system_dict_data (id, sort, label, value, dict_type, status, color_type, css_class, remark, creator, create_time, updater, update_time, deleted) VALUES (53, 0, '鍒濆鍖栦腑', '0', 'infra_job_status', 0, 'primary', '', NULL, '', '2021-02-07 07:46:49', '1', '2022-02-16 19:33:29', 0);
INSERT INTO public.system_dict_data (id, sort, label, value, dict_type, status, color_type, css_class, remark, creator, create_time, updater, update_time, deleted) VALUES (57, 0, '杩愯涓?, '0', 'infra_job_log_status', 0, 'primary', '', 'RUNNING', '', '2021-02-08 10:04:24', '1', '2022-02-16 19:07:48', 0);
INSERT INTO public.system_dict_data (id, sort, label, value, dict_type, status, color_type, css_class, remark, creator, create_time, updater, update_time, deleted) VALUES (58, 1, '鎴愬姛', '1', 'infra_job_log_status', 0, 'success', '', NULL, '', '2021-02-08 10:06:57', '1', '2022-02-16 19:07:52', 0);
INSERT INTO public.system_dict_data (id, sort, label, value, dict_type, status, color_type, css_class, remark, creator, create_time, updater, update_time, deleted) VALUES (59, 2, '澶辫触', '2', 'infra_job_log_status', 0, 'warning', '', '澶辫触', '', '2021-02-08 10:07:38', '1', '2022-02-16 19:07:56', 0);
INSERT INTO public.system_dict_data (id, sort, label, value, dict_type, status, color_type, css_class, remark, creator, create_time, updater, update_time, deleted) VALUES (60, 1, '浼氬憳', '1', 'user_type', 0, 'primary', '', NULL, '', '2021-02-26 00:16:27', '1', '2022-02-16 10:22:19', 0);
INSERT INTO public.system_dict_data (id, sort, label, value, dict_type, status, color_type, css_class, remark, creator, create_time, updater, update_time, deleted) VALUES (61, 2, '绠＄悊鍛?, '2', 'user_type', 0, 'success', '', NULL, '', '2021-02-26 00:16:34', '1', '2025-04-06 18:37:43', 0);
INSERT INTO public.system_dict_data (id, sort, label, value, dict_type, status, color_type, css_class, remark, creator, create_time, updater, update_time, deleted) VALUES (62, 0, '鏈鐞?, '0', 'infra_api_error_log_process_status', 0, 'primary', '', NULL, '', '2021-02-26 07:07:19', '1', '2022-02-16 20:14:17', 0);
INSERT INTO public.system_dict_data (id, sort, label, value, dict_type, status, color_type, css_class, remark, creator, create_time, updater, update_time, deleted) VALUES (63, 1, '宸插鐞?, '1', 'infra_api_error_log_process_status', 0, 'success', '', NULL, '', '2021-02-26 07:07:26', '1', '2022-02-16 20:14:08', 0);
INSERT INTO public.system_dict_data (id, sort, label, value, dict_type, status, color_type, css_class, remark, creator, create_time, updater, update_time, deleted) VALUES (64, 2, '宸插拷鐣?, '2', 'infra_api_error_log_process_status', 0, 'danger', '', NULL, '', '2021-02-26 07:07:34', '1', '2022-02-16 20:14:14', 0);
INSERT INTO public.system_dict_data (id, sort, label, value, dict_type, status, color_type, css_class, remark, creator, create_time, updater, update_time, deleted) VALUES (80, 100, '璐﹀彿鐧诲綍', '100', 'system_login_type', 0, 'primary', '', '璐﹀彿鐧诲綍', '1', '2021-10-06 00:52:02', '1', '2022-02-16 13:11:34', 0);
INSERT INTO public.system_dict_data (id, sort, label, value, dict_type, status, color_type, css_class, remark, creator, create_time, updater, update_time, deleted) VALUES (81, 101, '绀句氦鐧诲綍', '101', 'system_login_type', 0, 'info', '', '绀句氦鐧诲綍', '1', '2021-10-06 00:52:17', '1', '2022-02-16 13:11:40', 0);
INSERT INTO public.system_dict_data (id, sort, label, value, dict_type, status, color_type, css_class, remark, creator, create_time, updater, update_time, deleted) VALUES (83, 200, '涓诲姩鐧诲嚭', '200', 'system_login_type', 0, 'primary', '', '涓诲姩鐧诲嚭', '1', '2021-10-06 00:52:58', '1', '2022-02-16 13:11:49', 0);
INSERT INTO public.system_dict_data (id, sort, label, value, dict_type, status, color_type, css_class, remark, creator, create_time, updater, update_time, deleted) VALUES (85, 202, '寮哄埗鐧诲嚭', '202', 'system_login_type', 0, 'danger', '', '寮哄埗閫€鍑?, '1', '2021-10-06 00:53:41', '1', '2022-02-16 13:11:57', 0);
INSERT INTO public.system_dict_data (id, sort, label, value, dict_type, status, color_type, css_class, remark, creator, create_time, updater, update_time, deleted) VALUES (1194, 10, '寰俊灏忕▼搴?, '10', 'terminal', 0, 'default', '', '缁堢 - 寰俊灏忕▼搴?, '1', '2022-12-10 10:51:11', '1', '2022-12-10 10:51:57', 0);
INSERT INTO public.system_dict_data (id, sort, label, value, dict_type, status, color_type, css_class, remark, creator, create_time, updater, update_time, deleted) VALUES (1195, 20, 'H5 缃戦〉', '20', 'terminal', 0, 'default', '', '缁堢 - H5 缃戦〉', '1', '2022-12-10 10:51:30', '1', '2022-12-10 10:51:59', 0);
INSERT INTO public.system_dict_data (id, sort, label, value, dict_type, status, color_type, css_class, remark, creator, create_time, updater, update_time, deleted) VALUES (1196, 11, '寰俊鍏紬鍙?, '11', 'terminal', 0, 'default', '', '缁堢 - 寰俊鍏紬鍙?, '1', '2022-12-10 10:54:16', '1', '2022-12-10 10:52:01', 0);
INSERT INTO public.system_dict_data (id, sort, label, value, dict_type, status, color_type, css_class, remark, creator, create_time, updater, update_time, deleted) VALUES (1197, 31, '鑻规灉 App', '31', 'terminal', 0, 'default', '', '缁堢 - 鑻规灉 App', '1', '2022-12-10 10:54:42', '1', '2022-12-10 10:52:18', 0);
INSERT INTO public.system_dict_data (id, sort, label, value, dict_type, status, color_type, css_class, remark, creator, create_time, updater, update_time, deleted) VALUES (1198, 32, '瀹夊崜 App', '32', 'terminal', 0, 'default', '', '缁堢 - 瀹夊崜 App', '1', '2022-12-10 10:55:02', '1', '2022-12-10 10:59:17', 0);
INSERT INTO public.system_dict_data (id, sort, label, value, dict_type, status, color_type, css_class, remark, creator, create_time, updater, update_time, deleted) VALUES (1359, 1, '浜轰汉鍒嗛攢', '1', 'brokerage_enabled_condition', 0, '', '', '鎵€鏈夌敤鎴烽兘鍙互鍒嗛攢', '', '2023-09-28 02:46:05', '', '2023-09-28 02:46:05', 0);
INSERT INTO public.system_dict_data (id, sort, label, value, dict_type, status, color_type, css_class, remark, creator, create_time, updater, update_time, deleted) VALUES (1360, 2, '鎸囧畾鍒嗛攢', '2', 'brokerage_enabled_condition', 0, '', '', '浠呭彲鍚庡彴鎵嬪姩璁剧疆鎺ㄥ箍鍛?, '', '2023-09-28 02:46:05', '', '2023-09-28 02:46:05', 0);
INSERT INTO public.system_dict_data (id, sort, label, value, dict_type, status, color_type, css_class, remark, creator, create_time, updater, update_time, deleted) VALUES (1361, 1, '棣栨缁戝畾', '1', 'brokerage_bind_mode', 0, '', '', '鍙鐢ㄦ埛娌℃湁鎺ㄥ箍浜猴紝闅忔椂閮藉彲浠ョ粦瀹氭帹骞垮叧绯?, '', '2023-09-28 02:46:05', '', '2023-09-28 02:46:05', 0);
INSERT INTO public.system_dict_data (id, sort, label, value, dict_type, status, color_type, css_class, remark, creator, create_time, updater, update_time, deleted) VALUES (1362, 2, '娉ㄥ唽缁戝畾', '2', 'brokerage_bind_mode', 0, '', '', '浠呮柊鐢ㄦ埛娉ㄥ唽鏃舵墠鑳界粦瀹氭帹骞垮叧绯?, '', '2023-09-28 02:46:05', '', '2023-09-28 02:46:05', 0);
INSERT INTO public.system_dict_data (id, sort, label, value, dict_type, status, color_type, css_class, remark, creator, create_time, updater, update_time, deleted) VALUES (1363, 3, '瑕嗙洊缁戝畾', '3', 'brokerage_bind_mode', 0, '', '', '濡傛灉鐢ㄦ埛宸茬粡鏈夋帹骞夸汉锛屾帹骞夸汉浼氳鍙樻洿', '', '2023-09-28 02:46:05', '', '2023-09-28 02:46:05', 0);
INSERT INTO public.system_dict_data (id, sort, label, value, dict_type, status, color_type, css_class, remark, creator, create_time, updater, update_time, deleted) VALUES (1364, 1, '閽卞寘', '1', 'brokerage_withdraw_type', 0, '', '', NULL, '', '2023-09-28 02:46:05', '', '2023-09-28 02:46:05', 0);
INSERT INTO public.system_dict_data (id, sort, label, value, dict_type, status, color_type, css_class, remark, creator, create_time, updater, update_time, deleted) VALUES (1365, 2, '閾惰鍗?, '2', 'brokerage_withdraw_type', 0, '', '', NULL, '', '2023-09-28 02:46:05', '', '2023-09-28 02:46:05', 0);
INSERT INTO public.system_dict_data (id, sort, label, value, dict_type, status, color_type, css_class, remark, creator, create_time, updater, update_time, deleted) VALUES (1366, 3, '寰俊鏀舵鐮?, '3', 'brokerage_withdraw_type', 0, '', '', '鎵嬪姩鎵撴', '', '2023-09-28 02:46:05', '1', '2025-05-10 08:24:25', 0);
INSERT INTO public.system_dict_data (id, sort, label, value, dict_type, status, color_type, css_class, remark, creator, create_time, updater, update_time, deleted) VALUES (1367, 4, '鏀粯瀹濇敹娆剧爜', '4', 'brokerage_withdraw_type', 0, '', '', '鎵嬪姩鎵撴', '', '2023-09-28 02:46:05', '1', '2025-05-10 08:24:37', 0);
INSERT INTO public.system_dict_data (id, sort, label, value, dict_type, status, color_type, css_class, remark, creator, create_time, updater, update_time, deleted) VALUES (1368, 1, '璁㈠崟杩斾剑', '1', 'brokerage_record_biz_type', 0, '', '', NULL, '', '2023-09-28 02:46:05', '', '2023-09-28 02:46:05', 0);
INSERT INTO public.system_dict_data (id, sort, label, value, dict_type, status, color_type, css_class, remark, creator, create_time, updater, update_time, deleted) VALUES (1369, 2, '鐢宠鎻愮幇', '2', 'brokerage_record_biz_type', 0, '', '', NULL, '', '2023-09-28 02:46:05', '', '2023-09-28 02:46:05', 0);
INSERT INTO public.system_dict_data (id, sort, label, value, dict_type, status, color_type, css_class, remark, creator, create_time, updater, update_time, deleted) VALUES (1370, 3, '鐢宠鎻愮幇椹冲洖', '3', 'brokerage_record_biz_type', 0, '', '', NULL, '', '2023-09-28 02:46:05', '', '2023-09-28 02:46:05', 0);
INSERT INTO public.system_dict_data (id, sort, label, value, dict_type, status, color_type, css_class, remark, creator, create_time, updater, update_time, deleted) VALUES (1371, 0, '寰呯粨绠?, '0', 'brokerage_record_status', 0, '', '', NULL, '', '2023-09-28 02:46:05', '', '2023-09-28 02:46:05', 0);
INSERT INTO public.system_dict_data (id, sort, label, value, dict_type, status, color_type, css_class, remark, creator, create_time, updater, update_time, deleted) VALUES (1372, 1, '宸茬粨绠?, '1', 'brokerage_record_status', 0, '', '', NULL, '', '2023-09-28 02:46:05', '', '2023-09-28 02:46:05', 0);
INSERT INTO public.system_dict_data (id, sort, label, value, dict_type, status, color_type, css_class, remark, creator, create_time, updater, update_time, deleted) VALUES (1373, 2, '宸插彇娑?, '2', 'brokerage_record_status', 0, '', '', NULL, '', '2023-09-28 02:46:05', '', '2023-09-28 02:46:05', 0);
INSERT INTO public.system_dict_data (id, sort, label, value, dict_type, status, color_type, css_class, remark, creator, create_time, updater, update_time, deleted) VALUES (1374, 0, '瀹℃牳涓?, '0', 'brokerage_withdraw_status', 0, '', '', NULL, '', '2023-09-28 02:46:05', '', '2023-09-28 02:46:05', 0);
INSERT INTO public.system_dict_data (id, sort, label, value, dict_type, status, color_type, css_class, remark, creator, create_time, updater, update_time, deleted) VALUES (1375, 10, '瀹℃牳閫氳繃', '10', 'brokerage_withdraw_status', 0, 'success', '', NULL, '', '2023-09-28 02:46:05', '', '2023-09-28 02:46:05', 0);
INSERT INTO public.system_dict_data (id, sort, label, value, dict_type, status, color_type, css_class, remark, creator, create_time, updater, update_time, deleted) VALUES (1376, 11, '鎻愮幇鎴愬姛', '11', 'brokerage_withdraw_status', 0, 'success', '', NULL, '', '2023-09-28 02:46:05', '', '2023-09-28 02:46:05', 0);
INSERT INTO public.system_dict_data (id, sort, label, value, dict_type, status, color_type, css_class, remark, creator, create_time, updater, update_time, deleted) VALUES (1377, 20, '瀹℃牳涓嶉€氳繃', '20', 'brokerage_withdraw_status', 0, 'danger', '', NULL, '', '2023-09-28 02:46:05', '', '2023-09-28 02:46:05', 0);
INSERT INTO public.system_dict_data (id, sort, label, value, dict_type, status, color_type, css_class, remark, creator, create_time, updater, update_time, deleted) VALUES (1378, 21, '鎻愮幇澶辫触', '21', 'brokerage_withdraw_status', 0, 'danger', '', NULL, '', '2023-09-28 02:46:05', '', '2023-09-28 02:46:05', 0);
INSERT INTO public.system_dict_data (id, sort, label, value, dict_type, status, color_type, css_class, remark, creator, create_time, updater, update_time, deleted) VALUES (1379, 0, '宸ュ晢閾惰', '0', 'brokerage_bank_name', 0, '', '', NULL, '', '2023-09-28 02:46:05', '', '2023-09-28 02:46:05', 0);
INSERT INTO public.system_dict_data (id, sort, label, value, dict_type, status, color_type, css_class, remark, creator, create_time, updater, update_time, deleted) VALUES (1380, 1, '寤鸿閾惰', '1', 'brokerage_bank_name', 0, '', '', NULL, '', '2023-09-28 02:46:05', '', '2023-09-28 02:46:05', 0);
INSERT INTO public.system_dict_data (id, sort, label, value, dict_type, status, color_type, css_class, remark, creator, create_time, updater, update_time, deleted) VALUES (1381, 2, '鍐滀笟閾惰', '2', 'brokerage_bank_name', 0, '', '', NULL, '', '2023-09-28 02:46:05', '', '2023-09-28 02:46:05', 0);
INSERT INTO public.system_dict_data (id, sort, label, value, dict_type, status, color_type, css_class, remark, creator, create_time, updater, update_time, deleted) VALUES (1382, 3, '涓浗閾惰', '3', 'brokerage_bank_name', 0, '', '', NULL, '', '2023-09-28 02:46:05', '', '2023-09-28 02:46:05', 0);
INSERT INTO public.system_dict_data (id, sort, label, value, dict_type, status, color_type, css_class, remark, creator, create_time, updater, update_time, deleted) VALUES (1383, 4, '浜ら€氶摱琛?, '4', 'brokerage_bank_name', 0, '', '', NULL, '', '2023-09-28 02:46:05', '', '2023-09-28 02:46:05', 0);
INSERT INTO public.system_dict_data (id, sort, label, value, dict_type, status, color_type, css_class, remark, creator, create_time, updater, update_time, deleted) VALUES (1384, 5, '鎷涘晢閾惰', '5', 'brokerage_bank_name', 0, '', '', NULL, '', '2023-09-28 02:46:05', '', '2023-09-28 02:46:05', 0);
INSERT INTO public.system_dict_data (id, sort, label, value, dict_type, status, color_type, css_class, remark, creator, create_time, updater, update_time, deleted) VALUES (1529, 1, '澶?, '1', 'date_interval', 0, '', '', '', '1', '2024-03-29 22:50:26', '1', '2024-03-29 22:50:26', 0);
INSERT INTO public.system_dict_data (id, sort, label, value, dict_type, status, color_type, css_class, remark, creator, create_time, updater, update_time, deleted) VALUES (1530, 2, '鍛?, '2', 'date_interval', 0, '', '', '', '1', '2024-03-29 22:50:36', '1', '2024-03-29 22:50:36', 0);
INSERT INTO public.system_dict_data (id, sort, label, value, dict_type, status, color_type, css_class, remark, creator, create_time, updater, update_time, deleted) VALUES (1531, 3, '鏈?, '3', 'date_interval', 0, '', '', '', '1', '2024-03-29 22:50:46', '1', '2024-03-29 22:50:54', 0);
INSERT INTO public.system_dict_data (id, sort, label, value, dict_type, status, color_type, css_class, remark, creator, create_time, updater, update_time, deleted) VALUES (1532, 4, '瀛ｅ害', '4', 'date_interval', 0, '', '', '', '1', '2024-03-29 22:51:01', '1', '2024-03-29 22:51:01', 0);
INSERT INTO public.system_dict_data (id, sort, label, value, dict_type, status, color_type, css_class, remark, creator, create_time, updater, update_time, deleted) VALUES (1533, 5, '骞?, '5', 'date_interval', 0, '', '', '', '1', '2024-03-29 22:51:07', '1', '2024-03-29 22:51:07', 0);
INSERT INTO public.system_dict_data (id, sort, label, value, dict_type, status, color_type, css_class, remark, creator, create_time, updater, update_time, deleted) VALUES (1593, 5, '寰俊闆堕挶', '5', 'brokerage_withdraw_type', 0, '', '', 'API 鎵撴', '1', '2024-10-13 11:06:48', '1', '2025-05-10 08:24:55', 0);
INSERT INTO public.system_dict_data (id, sort, label, value, dict_type, status, color_type, css_class, remark, creator, create_time, updater, update_time, deleted) VALUES (3002, 6, '鏀粯瀹濅綑棰?, '6', 'brokerage_withdraw_type', 0, '', '', 'API 鎵撴', '1', '2025-05-10 08:24:49', '1', '2025-05-10 08:24:49', 0);


--
-- Data for Name: system_dict_type; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.system_dict_type (id, name, type, status, remark, creator, create_time, updater, update_time, deleted, deleted_time) VALUES (1, '鐢ㄦ埛鎬у埆', 'system_user_sex', 0, NULL, 'admin', '2021-01-05 17:03:48', '1', '2022-05-16 20:29:32', 0, NULL);
INSERT INTO public.system_dict_type (id, name, type, status, remark, creator, create_time, updater, update_time, deleted, deleted_time) VALUES (9, '鎿嶄綔绫诲瀷', 'infra_operate_type', 0, NULL, 'admin', '2021-01-05 17:03:48', '1', '2024-03-14 12:44:01', 0, NULL);
INSERT INTO public.system_dict_type (id, name, type, status, remark, creator, create_time, updater, update_time, deleted, deleted_time) VALUES (10, '绯荤粺鐘舵€?, 'common_status', 0, NULL, 'admin', '2021-01-05 17:03:48', '', '2022-02-01 16:21:28', 0, NULL);
INSERT INTO public.system_dict_type (id, name, type, status, remark, creator, create_time, updater, update_time, deleted, deleted_time) VALUES (11, 'Boolean 鏄惁绫诲瀷', 'infra_boolean_string', 0, 'boolean 杞槸鍚?, '', '2021-01-19 03:20:08', '', '2022-02-01 16:37:10', 0, NULL);
INSERT INTO public.system_dict_type (id, name, type, status, remark, creator, create_time, updater, update_time, deleted, deleted_time) VALUES (104, '鐧婚檰缁撴灉', 'system_login_result', 0, '鐧婚檰缁撴灉', '', '2021-01-18 06:17:11', '', '2022-02-01 16:36:00', 0, NULL);
INSERT INTO public.system_dict_type (id, name, type, status, remark, creator, create_time, updater, update_time, deleted, deleted_time) VALUES (107, '瀹氭椂浠诲姟鐘舵€?, 'infra_job_status', 0, NULL, '', '2021-02-07 07:44:16', '', '2022-02-01 16:51:11', 0, NULL);
INSERT INTO public.system_dict_type (id, name, type, status, remark, creator, create_time, updater, update_time, deleted, deleted_time) VALUES (108, '瀹氭椂浠诲姟鏃ュ織鐘舵€?, 'infra_job_log_status', 0, NULL, '', '2021-02-08 10:03:51', '', '2022-02-01 16:50:43', 0, NULL);
INSERT INTO public.system_dict_type (id, name, type, status, remark, creator, create_time, updater, update_time, deleted, deleted_time) VALUES (109, '鐢ㄦ埛绫诲瀷', 'user_type', 0, NULL, '', '2021-02-26 00:15:51', '', '2021-02-26 00:15:51', 0, NULL);
INSERT INTO public.system_dict_type (id, name, type, status, remark, creator, create_time, updater, update_time, deleted, deleted_time) VALUES (110, 'API 寮傚父鏁版嵁鐨勫鐞嗙姸鎬?, 'infra_api_error_log_process_status', 0, NULL, '', '2021-02-26 07:07:01', '', '2022-02-01 16:50:53', 0, NULL);
INSERT INTO public.system_dict_type (id, name, type, status, remark, creator, create_time, updater, update_time, deleted, deleted_time) VALUES (116, '鐧婚檰鏃ュ織鐨勭被鍨?, 'system_login_type', 0, '鐧婚檰鏃ュ織鐨勭被鍨?, '1', '2021-10-06 00:50:46', '1', '2022-02-01 16:35:56', 0, NULL);
INSERT INTO public.system_dict_type (id, name, type, status, remark, creator, create_time, updater, update_time, deleted, deleted_time) VALUES (145, '瑙掕壊绫诲瀷', 'system_role_type', 0, '瑙掕壊绫诲瀷', '1', '2022-02-16 13:01:46', '1', '2022-02-16 13:01:46', 0, NULL);
INSERT INTO public.system_dict_type (id, name, type, status, remark, creator, create_time, updater, update_time, deleted, deleted_time) VALUES (160, '缁堢', 'terminal', 0, '缁堢', '1', '2022-12-10 10:50:50', '1', '2022-12-10 10:53:11', 0, NULL);
INSERT INTO public.system_dict_type (id, name, type, status, remark, creator, create_time, updater, update_time, deleted, deleted_time) VALUES (176, '鍒嗕剑妯″紡', 'brokerage_enabled_condition', 0, NULL, '', '2023-09-28 02:46:05', '', '2023-09-28 02:46:05', 0, NULL);
INSERT INTO public.system_dict_type (id, name, type, status, remark, creator, create_time, updater, update_time, deleted, deleted_time) VALUES (177, '鍒嗛攢鍏崇郴缁戝畾妯″紡', 'brokerage_bind_mode', 0, NULL, '', '2023-09-28 02:46:05', '', '2023-09-28 02:46:05', 0, NULL);
INSERT INTO public.system_dict_type (id, name, type, status, remark, creator, create_time, updater, update_time, deleted, deleted_time) VALUES (178, '浣ｉ噾鎻愮幇绫诲瀷', 'brokerage_withdraw_type', 0, NULL, '', '2023-09-28 02:46:05', '', '2023-09-28 02:46:05', 0, NULL);
INSERT INTO public.system_dict_type (id, name, type, status, remark, creator, create_time, updater, update_time, deleted, deleted_time) VALUES (179, '浣ｉ噾璁板綍涓氬姟绫诲瀷', 'brokerage_record_biz_type', 0, NULL, '', '2023-09-28 02:46:05', '', '2023-09-28 02:46:05', 0, NULL);
INSERT INTO public.system_dict_type (id, name, type, status, remark, creator, create_time, updater, update_time, deleted, deleted_time) VALUES (180, '浣ｉ噾璁板綍鐘舵€?, 'brokerage_record_status', 0, NULL, '', '2023-09-28 02:46:05', '', '2023-09-28 02:46:05', 0, NULL);
INSERT INTO public.system_dict_type (id, name, type, status, remark, creator, create_time, updater, update_time, deleted, deleted_time) VALUES (181, '浣ｉ噾鎻愮幇鐘舵€?, 'brokerage_withdraw_status', 0, NULL, '', '2023-09-28 02:46:05', '', '2023-09-28 02:46:05', 0, NULL);
INSERT INTO public.system_dict_type (id, name, type, status, remark, creator, create_time, updater, update_time, deleted, deleted_time) VALUES (182, '浣ｉ噾鎻愮幇閾惰', 'brokerage_bank_name', 0, NULL, '', '2023-09-28 02:46:05', '', '2023-09-28 02:46:05', 0, NULL);
INSERT INTO public.system_dict_type (id, name, type, status, remark, creator, create_time, updater, update_time, deleted, deleted_time) VALUES (616, '鏃堕棿闂撮殧', 'date_interval', 0, '', '1', '2024-03-29 22:50:09', '1', '2024-03-29 22:50:09', 0, '1970-01-01 00:00:00');


--
-- Data for Name: system_login_log; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: system_menu; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.system_menu (id, name, permission, type, sort, parent_id, path, icon, component, component_name, status, visible, keep_alive, always_show, creator, create_time, updater, update_time, deleted) VALUES (1, '绯荤粺绠＄悊', '', 1, 10, 0, '/system', 'ep:tools', NULL, NULL, 0, true, true, true, 'admin', '2021-01-05 17:03:48', '1', '2025-03-15 21:30:27', 0);
INSERT INTO public.system_menu (id, name, permission, type, sort, parent_id, path, icon, component, component_name, status, visible, keep_alive, always_show, creator, create_time, updater, update_time, deleted) VALUES (2, '鍩虹璁炬柦', '', 1, 20, 0, '/infra', 'ep:monitor', NULL, NULL, 0, true, true, true, 'admin', '2021-01-05 17:03:48', '1', '2024-03-01 08:28:40', 0);
INSERT INTO public.system_menu (id, name, permission, type, sort, parent_id, path, icon, component, component_name, status, visible, keep_alive, always_show, creator, create_time, updater, update_time, deleted) VALUES (100, '鐢ㄦ埛绠＄悊', 'system:user:list', 2, 1, 1, 'user', 'ep:avatar', 'system/user/index', 'SystemUser', 0, true, true, true, 'admin', '2021-01-05 17:03:48', '1', '2026-01-01 18:43:01', 0);
INSERT INTO public.system_menu (id, name, permission, type, sort, parent_id, path, icon, component, component_name, status, visible, keep_alive, always_show, creator, create_time, updater, update_time, deleted) VALUES (101, '瑙掕壊绠＄悊', '', 2, 2, 1, 'role', 'ep:user', 'system/role/index', 'SystemRole', 0, true, true, true, 'admin', '2021-01-05 17:03:48', '1', '2026-01-05 19:30:33', 0);
INSERT INTO public.system_menu (id, name, permission, type, sort, parent_id, path, icon, component, component_name, status, visible, keep_alive, always_show, creator, create_time, updater, update_time, deleted) VALUES (102, '鑿滃崟绠＄悊', '', 2, 3, 1, 'menu', 'ep:menu', 'system/menu/index', 'SystemMenu', 0, true, true, true, 'admin', '2021-01-05 17:03:48', '1', '2024-02-29 01:03:50', 0);
INSERT INTO public.system_menu (id, name, permission, type, sort, parent_id, path, icon, component, component_name, status, visible, keep_alive, always_show, creator, create_time, updater, update_time, deleted) VALUES (103, '閮ㄩ棬绠＄悊', '', 2, 4, 1, 'dept', 'fa:address-card', 'system/dept/index', 'SystemDept', 0, true, true, true, 'admin', '2021-01-05 17:03:48', '1', '2024-02-29 01:06:28', 0);
INSERT INTO public.system_menu (id, name, permission, type, sort, parent_id, path, icon, component, component_name, status, visible, keep_alive, always_show, creator, create_time, updater, update_time, deleted) VALUES (104, '宀椾綅绠＄悊', '', 2, 5, 1, 'post', 'fa:address-book-o', 'system/post/index', 'SystemPost', 0, true, true, true, 'admin', '2021-01-05 17:03:48', '1', '2024-02-29 01:06:39', 0);
INSERT INTO public.system_menu (id, name, permission, type, sort, parent_id, path, icon, component, component_name, status, visible, keep_alive, always_show, creator, create_time, updater, update_time, deleted) VALUES (105, '瀛楀吀绠＄悊', '', 2, 6, 1, 'dict', 'ep:collection', 'system/dict/index', 'SystemDictType', 0, true, true, true, 'admin', '2021-01-05 17:03:48', '1', '2024-02-29 01:07:12', 0);
INSERT INTO public.system_menu (id, name, permission, type, sort, parent_id, path, icon, component, component_name, status, visible, keep_alive, always_show, creator, create_time, updater, update_time, deleted) VALUES (108, '瀹¤鏃ュ織', '', 1, 9, 1, 'log', 'ep:document-copy', '', NULL, 0, true, true, true, 'admin', '2021-01-05 17:03:48', '1', '2024-02-29 01:08:30', 0);
INSERT INTO public.system_menu (id, name, permission, type, sort, parent_id, path, icon, component, component_name, status, visible, keep_alive, always_show, creator, create_time, updater, update_time, deleted) VALUES (110, '瀹氭椂浠诲姟', '', 2, 7, 2, 'job', 'fa-solid:tasks', 'infra/job/index', 'InfraJob', 0, true, true, true, 'admin', '2021-01-05 17:03:48', '1', '2024-02-29 08:57:36', 0);
INSERT INTO public.system_menu (id, name, permission, type, sort, parent_id, path, icon, component, component_name, status, visible, keep_alive, always_show, creator, create_time, updater, update_time, deleted) VALUES (500, '鎿嶄綔鏃ュ織', '', 2, 1, 108, 'operate-log', 'ep:position', 'system/operatelog/index', 'SystemOperateLog', 0, true, true, true, 'admin', '2021-01-05 17:03:48', '1', '2024-02-29 01:09:59', 0);
INSERT INTO public.system_menu (id, name, permission, type, sort, parent_id, path, icon, component, component_name, status, visible, keep_alive, always_show, creator, create_time, updater, update_time, deleted) VALUES (501, '鐧诲綍鏃ュ織', '', 2, 2, 108, 'login-log', 'ep:promotion', 'system/loginlog/index', 'SystemLoginLog', 0, true, true, true, 'admin', '2021-01-05 17:03:48', '1', '2024-02-29 01:10:29', 0);
INSERT INTO public.system_menu (id, name, permission, type, sort, parent_id, path, icon, component, component_name, status, visible, keep_alive, always_show, creator, create_time, updater, update_time, deleted) VALUES (1001, '鐢ㄦ埛鏌ヨ', 'system:user:query', 3, 1, 100, '', '#', '', NULL, 0, true, true, true, 'admin', '2021-01-05 17:03:48', '', '2022-04-20 17:03:10', 0);
INSERT INTO public.system_menu (id, name, permission, type, sort, parent_id, path, icon, component, component_name, status, visible, keep_alive, always_show, creator, create_time, updater, update_time, deleted) VALUES (1002, '鐢ㄦ埛鏂板', 'system:user:create', 3, 2, 100, '', '', '', NULL, 0, true, true, true, 'admin', '2021-01-05 17:03:48', '1', '2022-04-20 17:03:10', 0);
INSERT INTO public.system_menu (id, name, permission, type, sort, parent_id, path, icon, component, component_name, status, visible, keep_alive, always_show, creator, create_time, updater, update_time, deleted) VALUES (1003, '鐢ㄦ埛淇敼', 'system:user:update', 3, 3, 100, '', '', '', NULL, 0, true, true, true, 'admin', '2021-01-05 17:03:48', '1', '2022-04-20 17:03:10', 0);
INSERT INTO public.system_menu (id, name, permission, type, sort, parent_id, path, icon, component, component_name, status, visible, keep_alive, always_show, creator, create_time, updater, update_time, deleted) VALUES (1004, '鐢ㄦ埛鍒犻櫎', 'system:user:delete', 3, 4, 100, '', '', '', NULL, 0, true, true, true, 'admin', '2021-01-05 17:03:48', '1', '2022-04-20 17:03:10', 0);
INSERT INTO public.system_menu (id, name, permission, type, sort, parent_id, path, icon, component, component_name, status, visible, keep_alive, always_show, creator, create_time, updater, update_time, deleted) VALUES (1005, '鐢ㄦ埛瀵煎嚭', 'system:user:export', 3, 5, 100, '', '#', '', NULL, 0, true, true, true, 'admin', '2021-01-05 17:03:48', '', '2022-04-20 17:03:10', 0);
INSERT INTO public.system_menu (id, name, permission, type, sort, parent_id, path, icon, component, component_name, status, visible, keep_alive, always_show, creator, create_time, updater, update_time, deleted) VALUES (1006, '鐢ㄦ埛瀵煎叆', 'system:user:import', 3, 6, 100, '', '#', '', NULL, 0, true, true, true, 'admin', '2021-01-05 17:03:48', '', '2022-04-20 17:03:10', 0);
INSERT INTO public.system_menu (id, name, permission, type, sort, parent_id, path, icon, component, component_name, status, visible, keep_alive, always_show, creator, create_time, updater, update_time, deleted) VALUES (1007, '閲嶇疆瀵嗙爜', 'system:user:update-password', 3, 7, 100, '', '', '', NULL, 0, true, true, true, 'admin', '2021-01-05 17:03:48', '1', '2022-04-20 17:03:10', 0);
INSERT INTO public.system_menu (id, name, permission, type, sort, parent_id, path, icon, component, component_name, status, visible, keep_alive, always_show, creator, create_time, updater, update_time, deleted) VALUES (1008, '瑙掕壊鏌ヨ', 'system:role:query', 3, 1, 101, '', '#', '', NULL, 0, true, true, true, 'admin', '2021-01-05 17:03:48', '', '2022-04-20 17:03:10', 0);
INSERT INTO public.system_menu (id, name, permission, type, sort, parent_id, path, icon, component, component_name, status, visible, keep_alive, always_show, creator, create_time, updater, update_time, deleted) VALUES (1009, '瑙掕壊鏂板', 'system:role:create', 3, 2, 101, '', '', '', NULL, 0, true, true, true, 'admin', '2021-01-05 17:03:48', '1', '2022-04-20 17:03:10', 0);
INSERT INTO public.system_menu (id, name, permission, type, sort, parent_id, path, icon, component, component_name, status, visible, keep_alive, always_show, creator, create_time, updater, update_time, deleted) VALUES (1010, '瑙掕壊淇敼', 'system:role:update', 3, 3, 101, '', '', '', NULL, 0, true, true, true, 'admin', '2021-01-05 17:03:48', '1', '2022-04-20 17:03:10', 0);
INSERT INTO public.system_menu (id, name, permission, type, sort, parent_id, path, icon, component, component_name, status, visible, keep_alive, always_show, creator, create_time, updater, update_time, deleted) VALUES (1011, '瑙掕壊鍒犻櫎', 'system:role:delete', 3, 4, 101, '', '', '', NULL, 0, true, true, true, 'admin', '2021-01-05 17:03:48', '1', '2022-04-20 17:03:10', 0);
INSERT INTO public.system_menu (id, name, permission, type, sort, parent_id, path, icon, component, component_name, status, visible, keep_alive, always_show, creator, create_time, updater, update_time, deleted) VALUES (1012, '瑙掕壊瀵煎嚭', 'system:role:export', 3, 5, 101, '', '#', '', NULL, 0, true, true, true, 'admin', '2021-01-05 17:03:48', '', '2022-04-20 17:03:10', 0);
INSERT INTO public.system_menu (id, name, permission, type, sort, parent_id, path, icon, component, component_name, status, visible, keep_alive, always_show, creator, create_time, updater, update_time, deleted) VALUES (1013, '鑿滃崟鏌ヨ', 'system:menu:query', 3, 1, 102, '', '#', '', NULL, 0, true, true, true, 'admin', '2021-01-05 17:03:48', '', '2022-04-20 17:03:10', 0);
INSERT INTO public.system_menu (id, name, permission, type, sort, parent_id, path, icon, component, component_name, status, visible, keep_alive, always_show, creator, create_time, updater, update_time, deleted) VALUES (1014, '鑿滃崟鏂板', 'system:menu:create', 3, 2, 102, '', '#', '', NULL, 0, true, true, true, 'admin', '2021-01-05 17:03:48', '', '2022-04-20 17:03:10', 0);
INSERT INTO public.system_menu (id, name, permission, type, sort, parent_id, path, icon, component, component_name, status, visible, keep_alive, always_show, creator, create_time, updater, update_time, deleted) VALUES (1015, '鑿滃崟淇敼', 'system:menu:update', 3, 3, 102, '', '#', '', NULL, 0, true, true, true, 'admin', '2021-01-05 17:03:48', '', '2022-04-20 17:03:10', 0);
INSERT INTO public.system_menu (id, name, permission, type, sort, parent_id, path, icon, component, component_name, status, visible, keep_alive, always_show, creator, create_time, updater, update_time, deleted) VALUES (1016, '鑿滃崟鍒犻櫎', 'system:menu:delete', 3, 4, 102, '', '#', '', NULL, 0, true, true, true, 'admin', '2021-01-05 17:03:48', '', '2022-04-20 17:03:10', 0);
INSERT INTO public.system_menu (id, name, permission, type, sort, parent_id, path, icon, component, component_name, status, visible, keep_alive, always_show, creator, create_time, updater, update_time, deleted) VALUES (1017, '閮ㄩ棬鏌ヨ', 'system:dept:query', 3, 1, 103, '', '#', '', NULL, 0, true, true, true, 'admin', '2021-01-05 17:03:48', '', '2022-04-20 17:03:10', 0);
INSERT INTO public.system_menu (id, name, permission, type, sort, parent_id, path, icon, component, component_name, status, visible, keep_alive, always_show, creator, create_time, updater, update_time, deleted) VALUES (1018, '閮ㄩ棬鏂板', 'system:dept:create', 3, 2, 103, '', '', '', NULL, 0, true, true, true, 'admin', '2021-01-05 17:03:48', '1', '2022-04-20 17:03:10', 0);
INSERT INTO public.system_menu (id, name, permission, type, sort, parent_id, path, icon, component, component_name, status, visible, keep_alive, always_show, creator, create_time, updater, update_time, deleted) VALUES (1019, '閮ㄩ棬淇敼', 'system:dept:update', 3, 3, 103, '', '', '', NULL, 0, true, true, true, 'admin', '2021-01-05 17:03:48', '1', '2022-04-20 17:03:10', 0);
INSERT INTO public.system_menu (id, name, permission, type, sort, parent_id, path, icon, component, component_name, status, visible, keep_alive, always_show, creator, create_time, updater, update_time, deleted) VALUES (1020, '閮ㄩ棬鍒犻櫎', 'system:dept:delete', 3, 4, 103, '', '', '', NULL, 0, true, true, true, 'admin', '2021-01-05 17:03:48', '1', '2022-04-20 17:03:10', 0);
INSERT INTO public.system_menu (id, name, permission, type, sort, parent_id, path, icon, component, component_name, status, visible, keep_alive, always_show, creator, create_time, updater, update_time, deleted) VALUES (1021, '宀椾綅鏌ヨ', 'system:post:query', 3, 1, 104, '', '#', '', NULL, 0, true, true, true, 'admin', '2021-01-05 17:03:48', '', '2022-04-20 17:03:10', 0);
INSERT INTO public.system_menu (id, name, permission, type, sort, parent_id, path, icon, component, component_name, status, visible, keep_alive, always_show, creator, create_time, updater, update_time, deleted) VALUES (1022, '宀椾綅鏂板', 'system:post:create', 3, 2, 104, '', '', '', NULL, 0, true, true, true, 'admin', '2021-01-05 17:03:48', '1', '2022-04-20 17:03:10', 0);
INSERT INTO public.system_menu (id, name, permission, type, sort, parent_id, path, icon, component, component_name, status, visible, keep_alive, always_show, creator, create_time, updater, update_time, deleted) VALUES (1023, '宀椾綅淇敼', 'system:post:update', 3, 3, 104, '', '', '', NULL, 0, true, true, true, 'admin', '2021-01-05 17:03:48', '1', '2022-04-20 17:03:10', 0);
INSERT INTO public.system_menu (id, name, permission, type, sort, parent_id, path, icon, component, component_name, status, visible, keep_alive, always_show, creator, create_time, updater, update_time, deleted) VALUES (1024, '宀椾綅鍒犻櫎', 'system:post:delete', 3, 4, 104, '', '', '', NULL, 0, true, true, true, 'admin', '2021-01-05 17:03:48', '1', '2022-04-20 17:03:10', 0);
INSERT INTO public.system_menu (id, name, permission, type, sort, parent_id, path, icon, component, component_name, status, visible, keep_alive, always_show, creator, create_time, updater, update_time, deleted) VALUES (1025, '宀椾綅瀵煎嚭', 'system:post:export', 3, 5, 104, '', '#', '', NULL, 0, true, true, true, 'admin', '2021-01-05 17:03:48', '', '2022-04-20 17:03:10', 0);
INSERT INTO public.system_menu (id, name, permission, type, sort, parent_id, path, icon, component, component_name, status, visible, keep_alive, always_show, creator, create_time, updater, update_time, deleted) VALUES (1026, '瀛楀吀鏌ヨ', 'system:dict:query', 3, 1, 105, '#', '#', '', NULL, 0, true, true, true, 'admin', '2021-01-05 17:03:48', '', '2022-04-20 17:03:10', 0);
INSERT INTO public.system_menu (id, name, permission, type, sort, parent_id, path, icon, component, component_name, status, visible, keep_alive, always_show, creator, create_time, updater, update_time, deleted) VALUES (1027, '瀛楀吀鏂板', 'system:dict:create', 3, 2, 105, '', '', '', NULL, 0, true, true, true, 'admin', '2021-01-05 17:03:48', '1', '2022-04-20 17:03:10', 0);
INSERT INTO public.system_menu (id, name, permission, type, sort, parent_id, path, icon, component, component_name, status, visible, keep_alive, always_show, creator, create_time, updater, update_time, deleted) VALUES (1028, '瀛楀吀淇敼', 'system:dict:update', 3, 3, 105, '', '', '', NULL, 0, true, true, true, 'admin', '2021-01-05 17:03:48', '1', '2022-04-20 17:03:10', 0);
INSERT INTO public.system_menu (id, name, permission, type, sort, parent_id, path, icon, component, component_name, status, visible, keep_alive, always_show, creator, create_time, updater, update_time, deleted) VALUES (1029, '瀛楀吀鍒犻櫎', 'system:dict:delete', 3, 4, 105, '', '', '', NULL, 0, true, true, true, 'admin', '2021-01-05 17:03:48', '1', '2022-04-20 17:03:10', 0);
INSERT INTO public.system_menu (id, name, permission, type, sort, parent_id, path, icon, component, component_name, status, visible, keep_alive, always_show, creator, create_time, updater, update_time, deleted) VALUES (1030, '瀛楀吀瀵煎嚭', 'system:dict:export', 3, 5, 105, '#', '#', '', NULL, 0, true, true, true, 'admin', '2021-01-05 17:03:48', '', '2022-04-20 17:03:10', 0);
INSERT INTO public.system_menu (id, name, permission, type, sort, parent_id, path, icon, component, component_name, status, visible, keep_alive, always_show, creator, create_time, updater, update_time, deleted) VALUES (1040, '鎿嶄綔鏌ヨ', 'system:operate-log:query', 3, 1, 500, '', '', '', NULL, 0, true, true, true, 'admin', '2021-01-05 17:03:48', '', '2022-04-20 17:03:10', 0);
INSERT INTO public.system_menu (id, name, permission, type, sort, parent_id, path, icon, component, component_name, status, visible, keep_alive, always_show, creator, create_time, updater, update_time, deleted) VALUES (1042, '鏃ュ織瀵煎嚭', 'system:operate-log:export', 3, 2, 500, '', '', '', NULL, 0, true, true, true, 'admin', '2021-01-05 17:03:48', '', '2022-04-20 17:03:10', 0);
INSERT INTO public.system_menu (id, name, permission, type, sort, parent_id, path, icon, component, component_name, status, visible, keep_alive, always_show, creator, create_time, updater, update_time, deleted) VALUES (1043, '鐧诲綍鏌ヨ', 'system:login-log:query', 3, 1, 501, '#', '#', '', NULL, 0, true, true, true, 'admin', '2021-01-05 17:03:48', '', '2022-04-20 17:03:10', 0);
INSERT INTO public.system_menu (id, name, permission, type, sort, parent_id, path, icon, component, component_name, status, visible, keep_alive, always_show, creator, create_time, updater, update_time, deleted) VALUES (1045, '鏃ュ織瀵煎嚭', 'system:login-log:export', 3, 3, 501, '#', '#', '', NULL, 0, true, true, true, 'admin', '2021-01-05 17:03:48', '', '2022-04-20 17:03:10', 0);
INSERT INTO public.system_menu (id, name, permission, type, sort, parent_id, path, icon, component, component_name, status, visible, keep_alive, always_show, creator, create_time, updater, update_time, deleted) VALUES (1050, '浠诲姟鏂板', 'infra:job:create', 3, 2, 110, '', '', '', NULL, 0, true, true, true, 'admin', '2021-01-05 17:03:48', '', '2022-04-20 17:03:10', 0);
INSERT INTO public.system_menu (id, name, permission, type, sort, parent_id, path, icon, component, component_name, status, visible, keep_alive, always_show, creator, create_time, updater, update_time, deleted) VALUES (1051, '浠诲姟淇敼', 'infra:job:update', 3, 3, 110, '', '', '', NULL, 0, true, true, true, 'admin', '2021-01-05 17:03:48', '', '2022-04-20 17:03:10', 0);
INSERT INTO public.system_menu (id, name, permission, type, sort, parent_id, path, icon, component, component_name, status, visible, keep_alive, always_show, creator, create_time, updater, update_time, deleted) VALUES (1052, '浠诲姟鍒犻櫎', 'infra:job:delete', 3, 4, 110, '', '', '', NULL, 0, true, true, true, 'admin', '2021-01-05 17:03:48', '', '2022-04-20 17:03:10', 0);
INSERT INTO public.system_menu (id, name, permission, type, sort, parent_id, path, icon, component, component_name, status, visible, keep_alive, always_show, creator, create_time, updater, update_time, deleted) VALUES (1053, '鐘舵€佷慨鏀?, 'infra:job:update', 3, 5, 110, '', '', '', NULL, 0, true, true, true, 'admin', '2021-01-05 17:03:48', '', '2022-04-20 17:03:10', 0);
INSERT INTO public.system_menu (id, name, permission, type, sort, parent_id, path, icon, component, component_name, status, visible, keep_alive, always_show, creator, create_time, updater, update_time, deleted) VALUES (1054, '浠诲姟瀵煎嚭', 'infra:job:export', 3, 7, 110, '', '', '', NULL, 0, true, true, true, 'admin', '2021-01-05 17:03:48', '', '2022-04-20 17:03:10', 0);
INSERT INTO public.system_menu (id, name, permission, type, sort, parent_id, path, icon, component, component_name, status, visible, keep_alive, always_show, creator, create_time, updater, update_time, deleted) VALUES (1063, '璁剧疆瑙掕壊鑿滃崟鏉冮檺', 'system:permission:assign-role-menu', 3, 6, 101, '', '', '', NULL, 0, true, true, true, '', '2021-01-06 17:53:44', '', '2022-04-20 17:03:10', 0);
INSERT INTO public.system_menu (id, name, permission, type, sort, parent_id, path, icon, component, component_name, status, visible, keep_alive, always_show, creator, create_time, updater, update_time, deleted) VALUES (1064, '璁剧疆瑙掕壊鏁版嵁鏉冮檺', 'system:permission:assign-role-data-scope', 3, 7, 101, '', '', '', NULL, 0, true, true, true, '', '2021-01-06 17:56:31', '', '2022-04-20 17:03:10', 0);
INSERT INTO public.system_menu (id, name, permission, type, sort, parent_id, path, icon, component, component_name, status, visible, keep_alive, always_show, creator, create_time, updater, update_time, deleted) VALUES (1065, '璁剧疆鐢ㄦ埛瑙掕壊', 'system:permission:assign-user-role', 3, 8, 101, '', '', '', NULL, 0, true, true, true, '', '2021-01-07 10:23:28', '', '2022-04-20 17:03:10', 0);
INSERT INTO public.system_menu (id, name, permission, type, sort, parent_id, path, icon, component, component_name, status, visible, keep_alive, always_show, creator, create_time, updater, update_time, deleted) VALUES (1075, '浠诲姟瑙﹀彂', 'infra:job:trigger', 3, 8, 110, '', '', '', NULL, 0, true, true, true, '', '2021-02-07 13:03:10', '', '2022-04-20 17:03:10', 0);
INSERT INTO public.system_menu (id, name, permission, type, sort, parent_id, path, icon, component, component_name, status, visible, keep_alive, always_show, creator, create_time, updater, update_time, deleted) VALUES (1078, '璁块棶鏃ュ織', '', 2, 1, 1083, 'api-access-log', 'ep:place', 'infra/apiAccessLog/index', 'InfraApiAccessLog', 0, true, true, true, '', '2021-02-26 01:32:59', '1', '2024-02-29 08:54:57', 0);
INSERT INTO public.system_menu (id, name, permission, type, sort, parent_id, path, icon, component, component_name, status, visible, keep_alive, always_show, creator, create_time, updater, update_time, deleted) VALUES (1082, '鏃ュ織瀵煎嚭', 'infra:api-access-log:export', 3, 2, 1078, '', '', '', NULL, 0, true, true, true, '', '2021-02-26 01:32:59', '1', '2022-04-20 17:03:10', 0);
INSERT INTO public.system_menu (id, name, permission, type, sort, parent_id, path, icon, component, component_name, status, visible, keep_alive, always_show, creator, create_time, updater, update_time, deleted) VALUES (1083, 'API 鏃ュ織', '', 2, 4, 2, 'log', 'fa:tasks', NULL, NULL, 0, true, true, true, '', '2021-02-26 02:18:24', '1', '2024-04-22 23:58:36', 0);
INSERT INTO public.system_menu (id, name, permission, type, sort, parent_id, path, icon, component, component_name, status, visible, keep_alive, always_show, creator, create_time, updater, update_time, deleted) VALUES (1084, '閿欒鏃ュ織', 'infra:api-error-log:query', 2, 2, 1083, 'api-error-log', 'ep:warning-filled', 'infra/apiErrorLog/index', 'InfraApiErrorLog', 0, true, true, true, '', '2021-02-26 07:53:20', '1', '2024-02-29 08:55:17', 0);
INSERT INTO public.system_menu (id, name, permission, type, sort, parent_id, path, icon, component, component_name, status, visible, keep_alive, always_show, creator, create_time, updater, update_time, deleted) VALUES (1085, '鏃ュ織澶勭悊', 'infra:api-error-log:update-status', 3, 2, 1084, '', '', '', NULL, 0, true, true, true, '', '2021-02-26 07:53:20', '1', '2022-04-20 17:03:10', 0);
INSERT INTO public.system_menu (id, name, permission, type, sort, parent_id, path, icon, component, component_name, status, visible, keep_alive, always_show, creator, create_time, updater, update_time, deleted) VALUES (1086, '鏃ュ織瀵煎嚭', 'infra:api-error-log:export', 3, 3, 1084, '', '', '', NULL, 0, true, true, true, '', '2021-02-26 07:53:20', '1', '2022-04-20 17:03:10', 0);
INSERT INTO public.system_menu (id, name, permission, type, sort, parent_id, path, icon, component, component_name, status, visible, keep_alive, always_show, creator, create_time, updater, update_time, deleted) VALUES (1087, '浠诲姟鏌ヨ', 'infra:job:query', 3, 1, 110, '', '', '', NULL, 0, true, true, true, '1', '2021-03-10 01:26:19', '1', '2022-04-20 17:03:10', 0);
INSERT INTO public.system_menu (id, name, permission, type, sort, parent_id, path, icon, component, component_name, status, visible, keep_alive, always_show, creator, create_time, updater, update_time, deleted) VALUES (1088, '鏃ュ織鏌ヨ', 'infra:api-access-log:query', 3, 1, 1078, '', '', '', NULL, 0, true, true, true, '1', '2021-03-10 01:28:04', '1', '2022-04-20 17:03:10', 0);
INSERT INTO public.system_menu (id, name, permission, type, sort, parent_id, path, icon, component, component_name, status, visible, keep_alive, always_show, creator, create_time, updater, update_time, deleted) VALUES (1089, '鏃ュ織鏌ヨ', 'infra:api-error-log:query', 3, 1, 1084, '', '', '', NULL, 0, true, true, true, '1', '2021-03-10 01:29:09', '1', '2022-04-20 17:03:10', 0);
INSERT INTO public.system_menu (id, name, permission, type, sort, parent_id, path, icon, component, component_name, status, visible, keep_alive, always_show, creator, create_time, updater, update_time, deleted) VALUES (1150, '绉橀挜瑙ｆ瀽', '', 3, 6, 1129, '', '', '', NULL, 0, true, true, true, '1', '2021-11-08 15:15:47', '1', '2022-04-20 17:03:10', 0);
INSERT INTO public.system_menu (id, name, permission, type, sort, parent_id, path, icon, component, component_name, status, visible, keep_alive, always_show, creator, create_time, updater, update_time, deleted) VALUES (5987, '鏂囦欢绠＄悊', '', 2, 8, 2, 'file', 'ep:folder-opened', 'infra/file/index', 'InfraFile', 0, true, true, true, '1', '2026-05-31 00:00:00', '1', '2026-05-31 00:00:00', 0);
INSERT INTO public.system_menu (id, name, permission, type, sort, parent_id, path, icon, component, component_name, status, visible, keep_alive, always_show, creator, create_time, updater, update_time, deleted) VALUES (5988, '鏂囦欢鏌ヨ', 'infra:file:query', 3, 1, 5987, '', '', '', NULL, 0, true, true, true, '1', '2026-05-31 00:00:00', '1', '2026-05-31 00:00:00', 0);
INSERT INTO public.system_menu (id, name, permission, type, sort, parent_id, path, icon, component, component_name, status, visible, keep_alive, always_show, creator, create_time, updater, update_time, deleted) VALUES (5989, '鏂囦欢涓婁紶', 'infra:file:create', 3, 2, 5987, '', '', '', NULL, 0, true, true, true, '1', '2026-05-31 00:00:00', '1', '2026-05-31 00:00:00', 0);
INSERT INTO public.system_menu (id, name, permission, type, sort, parent_id, path, icon, component, component_name, status, visible, keep_alive, always_show, creator, create_time, updater, update_time, deleted) VALUES (5990, '鏂囦欢鍒犻櫎', 'infra:file:delete', 3, 3, 5987, '', '', '', NULL, 0, true, true, true, '1', '2026-05-31 00:00:00', '1', '2026-05-31 00:00:00', 0);
INSERT INTO public.system_menu (id, name, permission, type, sort, parent_id, path, icon, component, component_name, status, visible, keep_alive, always_show, creator, create_time, updater, update_time, deleted) VALUES (2166, '闂ㄥ簵鑷彁', '', 1, 1, 2164, 'pick-up-store', 'ep:add-location', '', '', 0, true, true, true, '1', '2023-05-18 09:23:14', '1', '2023-08-30 21:03:21', 0);
INSERT INTO public.system_menu (id, name, permission, type, sort, parent_id, path, icon, component, component_name, status, visible, keep_alive, always_show, creator, create_time, updater, update_time, deleted) VALUES (2282, '绉垎绛惧埌瑙勫垯鏌ヨ', 'point:sign-in-config:query', 3, 1, 2281, '', '', '', NULL, 0, true, true, true, '', '2023-06-10 03:26:12', '', '2023-06-10 03:26:12', 0);
INSERT INTO public.system_menu (id, name, permission, type, sort, parent_id, path, icon, component, component_name, status, visible, keep_alive, always_show, creator, create_time, updater, update_time, deleted) VALUES (2283, '绉垎绛惧埌瑙勫垯鍒涘缓', 'point:sign-in-config:create', 3, 2, 2281, '', '', '', NULL, 0, true, true, true, '', '2023-06-10 03:26:12', '', '2023-06-10 03:26:12', 0);
INSERT INTO public.system_menu (id, name, permission, type, sort, parent_id, path, icon, component, component_name, status, visible, keep_alive, always_show, creator, create_time, updater, update_time, deleted) VALUES (2284, '绉垎绛惧埌瑙勫垯鏇存柊', 'point:sign-in-config:update', 3, 3, 2281, '', '', '', NULL, 0, true, true, true, '', '2023-06-10 03:26:12', '', '2023-06-10 03:26:12', 0);
INSERT INTO public.system_menu (id, name, permission, type, sort, parent_id, path, icon, component, component_name, status, visible, keep_alive, always_show, creator, create_time, updater, update_time, deleted) VALUES (2285, '绉垎绛惧埌瑙勫垯鍒犻櫎', 'point:sign-in-config:delete', 3, 4, 2281, '', '', '', NULL, 0, true, true, true, '', '2023-06-10 03:26:12', '', '2023-06-10 03:26:12', 0);
INSERT INTO public.system_menu (id, name, permission, type, sort, parent_id, path, icon, component, component_name, status, visible, keep_alive, always_show, creator, create_time, updater, update_time, deleted) VALUES (2288, '鐢ㄦ埛绉垎璁板綍鏌ヨ', 'point:record:query', 3, 1, 2287, '', '', '', NULL, 0, true, true, true, '', '2023-06-10 04:18:50', '', '2023-06-10 04:18:50', 0);
INSERT INTO public.system_menu (id, name, permission, type, sort, parent_id, path, icon, component, component_name, status, visible, keep_alive, always_show, creator, create_time, updater, update_time, deleted) VALUES (2294, '鐢ㄦ埛绛惧埌绉垎鏌ヨ', 'point:sign-in-record:query', 3, 1, 2293, '', '', '', NULL, 0, true, true, true, '', '2023-06-10 04:48:22', '', '2023-06-10 04:48:22', 0);
INSERT INTO public.system_menu (id, name, permission, type, sort, parent_id, path, icon, component, component_name, status, visible, keep_alive, always_show, creator, create_time, updater, update_time, deleted) VALUES (2297, '鐢ㄦ埛绛惧埌绉垎鍒犻櫎', 'point:sign-in-record:delete', 3, 4, 2293, '', '', '', NULL, 0, true, true, true, '', '2023-06-10 04:48:22', '', '2023-06-10 04:48:22', 0);
INSERT INTO public.system_menu (id, name, permission, type, sort, parent_id, path, icon, component, component_name, status, visible, keep_alive, always_show, creator, create_time, updater, update_time, deleted) VALUES (2551, '閽卞寘绠＄悊', '', 1, 4, 1117, 'wallet', 'ep:wallet', '', '', 0, true, true, true, '', '2023-12-29 02:32:54', '1', '2024-02-29 08:58:54', 0);
INSERT INTO public.system_menu (id, name, permission, type, sort, parent_id, path, icon, component, component_name, status, visible, keep_alive, always_show, creator, create_time, updater, update_time, deleted) VALUES (2560, '鏁版嵁缁熻', '', 1, 200, 2397, 'statistics', 'ep:data-line', '', '', 0, true, true, true, '1', '2024-01-26 22:50:35', '1', '2024-02-24 20:10:07', 0);
INSERT INTO public.system_menu (id, name, permission, type, sort, parent_id, path, icon, component, component_name, status, visible, keep_alive, always_show, creator, create_time, updater, update_time, deleted) VALUES (2564, '浜у搧绠＄悊', '', 1, 40, 2563, 'product', 'fa:product-hunt', '', '', 0, true, true, true, '1', '2024-02-04 15:38:43', '1', '2024-02-04 15:38:43', 0);
INSERT INTO public.system_menu (id, name, permission, type, sort, parent_id, path, icon, component, component_name, status, visible, keep_alive, always_show, creator, create_time, updater, update_time, deleted) VALUES (2583, '搴撳瓨绠＄悊', '', 1, 30, 2563, 'stock', 'fa:window-restore', '', '', 0, true, true, true, '1', '2024-02-05 00:29:37', '1', '2024-02-05 00:29:37', 0);
INSERT INTO public.system_menu (id, name, permission, type, sort, parent_id, path, icon, component, component_name, status, visible, keep_alive, always_show, creator, create_time, updater, update_time, deleted) VALUES (2602, '閲囪喘绠＄悊', '', 1, 10, 2563, 'purchase', 'fa:buysellads', '', '', 0, true, true, true, '1', '2024-02-06 16:01:01', '1', '2024-02-06 16:01:23', 0);
INSERT INTO public.system_menu (id, name, permission, type, sort, parent_id, path, icon, component, component_name, status, visible, keep_alive, always_show, creator, create_time, updater, update_time, deleted) VALUES (2617, '閿€鍞鐞?, '', 1, 20, 2563, 'sale', 'fa:sellsy', '', '', 0, true, true, true, '1', '2024-02-07 15:12:32', '1', '2024-02-07 15:12:32', 0);
INSERT INTO public.system_menu (id, name, permission, type, sort, parent_id, path, icon, component, component_name, status, visible, keep_alive, always_show, creator, create_time, updater, update_time, deleted) VALUES (2645, '璐㈠姟绠＄悊', '', 1, 50, 2563, 'finance', 'ep:money', '', '', 0, true, true, true, '1', '2024-02-10 08:05:58', '1', '2024-02-10 08:06:07', 0);
INSERT INTO public.system_menu (id, name, permission, type, sort, parent_id, path, icon, component, component_name, status, visible, keep_alive, always_show, creator, create_time, updater, update_time, deleted) VALUES (4001, '璁惧鎺ュ叆', '', 1, 2, 4000, 'device', 'ep:platform', '', '', 0, true, true, true, '1', '2024-08-10 09:57:56', '1', '2025-02-27 08:39:49', 0);
INSERT INTO public.system_menu (id, name, permission, type, sort, parent_id, path, icon, component, component_name, status, visible, keep_alive, always_show, creator, create_time, updater, update_time, deleted) VALUES (4047, '杩愮淮绠＄悊', '', 1, 4, 4000, 'operation', 'fa:align-center', '', '', 0, true, true, true, '1', '2025-02-05 22:21:37', '"1"', '2025-06-30 20:12:48', 0);
INSERT INTO public.system_menu (id, name, permission, type, sort, parent_id, path, icon, component, component_name, status, visible, keep_alive, always_show, creator, create_time, updater, update_time, deleted) VALUES (4048, '瑙勫垯寮曟搸', '', 1, 3, 4000, 'rule', 'fa-solid:cogs', '', '', 0, true, true, true, '1', '2025-02-11 14:10:54', '1', '2025-02-11 14:10:54', 0);
INSERT INTO public.system_menu (id, name, permission, type, sort, parent_id, path, icon, component, component_name, status, visible, keep_alive, always_show, creator, create_time, updater, update_time, deleted) VALUES (5028, '鍛婅涓績', '', 1, 3, 4000, 'alert', 'fa:soundcloud', '', '', 0, true, true, true, '1', '2025-06-27 22:30:04', '1', '2025-06-27 22:30:19', 0);
INSERT INTO public.system_menu (id, name, permission, type, sort, parent_id, path, icon, component, component_name, status, visible, keep_alive, always_show, creator, create_time, updater, update_time, deleted) VALUES (5101, '鍩虹鏁版嵁', '', 1, 10, 5100, 'md', 'ep:data-analysis', '', '', 0, true, true, true, '1', '2026-02-15 00:40:13', '1', '2026-02-15 00:40:13', 0);
INSERT INTO public.system_menu (id, name, permission, type, sort, parent_id, path, icon, component, component_name, status, visible, keep_alive, always_show, creator, create_time, updater, update_time, deleted) VALUES (5200, '鎺掔彮绠＄悊', '', 1, 70, 5100, 'cal', 'ep:calendar', '', '', 0, true, true, true, '1', '2026-02-16 07:35:50', '1', '2026-02-16 15:37:53', 0);
INSERT INTO public.system_menu (id, name, permission, type, sort, parent_id, path, icon, component, component_name, status, visible, keep_alive, always_show, creator, create_time, updater, update_time, deleted) VALUES (5300, '璁惧绠＄悊', '', 1, 30, 5100, 'dv', 'ep:cpu', '', '', 0, true, true, true, '1', '2026-02-17 00:59:58', '1', '2026-02-17 09:01:18', 0);
INSERT INTO public.system_menu (id, name, permission, type, sort, parent_id, path, icon, component, component_name, status, visible, keep_alive, always_show, creator, create_time, updater, update_time, deleted) VALUES (5400, '宸ュ叿绠＄悊', '', 1, 40, 5100, 'tm', 'ep:scissor', '', '', 0, true, true, true, '1', '2026-02-16 11:10:55', '1', '2026-03-21 14:20:41', 0);
INSERT INTO public.system_menu (id, name, permission, type, sort, parent_id, path, icon, component, component_name, status, visible, keep_alive, always_show, creator, create_time, updater, update_time, deleted) VALUES (5500, '璐ㄩ噺绠＄悊', '', 1, 60, 5100, 'qc', 'ep:check', '', '', 0, true, true, true, '1', '2026-02-17 02:18:18', '1', '2026-02-17 14:36:15', 0);
INSERT INTO public.system_menu (id, name, permission, type, sort, parent_id, path, icon, component, component_name, status, visible, keep_alive, always_show, creator, create_time, updater, update_time, deleted) VALUES (5700, '鐢熶骇绠＄悊', '', 1, 50, 5100, 'pro', 'ep:management', '', '', 0, true, true, true, '1', '2026-02-17 11:39:58', '1', '2026-02-17 19:53:35', 0);
INSERT INTO public.system_menu (id, name, permission, type, sort, parent_id, path, icon, component, component_name, status, visible, keep_alive, always_show, creator, create_time, updater, update_time, deleted) VALUES (5780, '浠撳簱绠＄悊', '', 1, 20, 5100, 'wm', 'ep:box', '', '', 0, true, true, true, '1', '2026-02-17 15:37:58', '1', '2026-02-17 23:38:18', 0);
INSERT INTO public.system_menu (id, name, permission, type, sort, parent_id, path, icon, component, component_name, status, visible, keep_alive, always_show, creator, create_time, updater, update_time, deleted) VALUES (5950, '搴撳瓨鐩樼偣', '', 1, 13, 5780, 'stock-taking', 'ep:circle-check-filled', '', '', 0, true, true, true, '1', '2026-03-09 00:00:00', '1', '2026-03-09 21:19:09', 0);



