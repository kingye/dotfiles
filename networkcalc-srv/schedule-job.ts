import cds from "@sap/cds";
import { DwcEnvContext, DwcRequestContext } from "@dwc/nodejs-utils";
import got, { Options as GotOptions, HTTPError } from "got";

type TimeFormat = {
    date: string;
    format: string;
};

export type ScheduleDefinition = {
    data: { [key: string]: any };
    description?: string;
    active?: boolean;
    startTime?: string | TimeFormat | null;
    endTime?: string | TimeFormat | null;
    cron?: string;
    time?: TimeFormat;
    repeatInterval?: string;
    repeatAt?: string;
    scheduleId?: number | string;
    nextRunAt?: string;
};

export type JobDefinition = {
    _id?: number;
    jobId?: number;
    name: string;
    description?: string;
    action?: string;
    active?: boolean;
    httpMethod?: string;
    startTime?: TimeFormat;
    endTime?: TimeFormat;
    schedules: ScheduleDefinition[];
};

/**
 * A wrapper of job-client.
 */
export class ScheduleJob {
    static JOB_SCHEDULER_URL = "/job-scheduler/v1";
    private readonly requestUrl: string;
    private constructor(
        private readonly dwcReq: DwcRequestContext,
        private readonly operationId?: string
    ) {
        if (this.operationId) {
            this.requestUrl = `${DwcEnvContext.getDwcMegacliteUrl()}/v1/migration${ScheduleJob.JOB_SCHEDULER_URL}`;
        } else {
            this.requestUrl = `${DwcEnvContext.getDwcMegacliteUrl()}/v1${ScheduleJob.JOB_SCHEDULER_URL}`;
        }
    }

    public static createInstance(dwcReq: DwcRequestContext, operationId?: string): ScheduleJob {
        return new ScheduleJob(dwcReq, operationId);
    }
    private getRequestOptions(method: "get" | "post" | "put" | "delete", additionalRequestOptions: GotOptions = {}) {
        const requestOptions: GotOptions = {
            resolveBodyOnly: true,
            retry: 0,
            method,
            ...additionalRequestOptions
        };
        const cfCertificate = DwcEnvContext.getInstanceCertificates();

        // Append Dwc Headers to existing headers
        requestOptions.headers = requestOptions.headers ? { ...requestOptions.headers, ...this.dwcReq.headers } : { ...this.dwcReq.headers };
        if (this.operationId) {
            requestOptions.headers["DwC-Operation-Id"] = this.operationId;
        }
        if (cfCertificate) {
            requestOptions.https = requestOptions.https ? { ...requestOptions.https, ...cfCertificate } : { ...cfCertificate };
        }
        return requestOptions;
    }

    public async getJob(jobName: string): Promise<JobDefinition | undefined> {
        try {
            return (await got(
                `${this.requestUrl}/scheduler/jobs?name=${jobName}&displaySchedules=true`,
                this.getRequestOptions("get", { responseType: "json" })
            )) as JobDefinition;
        } catch (err) {
            if ((err as HTTPError).response?.statusCode === 404) {
                return undefined;
            }
            throw err;
        }
    }

    public async deleteJob(jobId: number): Promise<void> {
        return got(
            `${this.requestUrl}/scheduler/jobs/${jobId}`,
            this.getRequestOptions("delete", {
                responseType: "json"
            })
        ) as Promise<void>;
    }

    public async deployJobs(jobs: JobDefinition[]): Promise<void> {
        const logger = (cds as any).log("job-schedule");
        // eslint-disable-next-line custom-lint-rules/await-all
        await Promise.all(
            jobs.map(async (job) => {
                const jid = await this.getJob(job.name);
                if (jid !== undefined) {
                    logger.info(`Job ${job.name} already exists. update it.`);
                    // eslint-disable-next-line no-underscore-dangle
                    await this.configJob(jid._id!, job);
                    const schedulesWithId = job.schedules.map((s) => {
                        const found = jid.schedules?.find((f) => f.description === s.description);
                        s.scheduleId = found?.scheduleId;
                        return s;
                    });
                    const toUpdate = schedulesWithId.filter((s) => s.scheduleId);
                    const toCreate = schedulesWithId.filter((s) => !s.scheduleId);
                    // eslint-disable-next-line custom-lint-rules/await-all
                    await Promise.all(
                        toUpdate.map((s) => {
                            logger.info(`Update job ${job.name} schedule ${s.scheduleId}`);
                            // eslint-disable-next-line no-underscore-dangle
                            return this.configSchedule(jid._id!, s.scheduleId!, { ...s, scheduleId: undefined });
                        })
                    );

                    // eslint-disable-next-line custom-lint-rules/await-all
                    await Promise.all(
                        toCreate.map((s) => {
                            logger.info(`Create job ${job.name} schedule ${s.scheduleId}`);
                            // eslint-disable-next-line no-underscore-dangle
                            return this.createSchedule(jid._id!, s);
                        })
                    );
                } else {
                    const njid = await this.createJob(job);
                    logger.info(`Job ${job.name} created with id ${njid}`);
                }
            })
        );
    }

    public async createJob(job: JobDefinition): Promise<number> {
        const response = await got(
            `${this.requestUrl}/scheduler/jobs`,
            this.getRequestOptions("post", {
                json: job,
                responseType: "json"
            })
        );
        // eslint-disable-next-line no-underscore-dangle
        return (response as any)._id;
    }

    public async updateJobRunLog(jobId: number | string, scheduleId: string, runId: number | string, data: any): Promise<void> {
        return got(
            `${this.requestUrl}/scheduler/jobs/${jobId}/schedules/${scheduleId}/runs/${runId}`,
            this.getRequestOptions("put", {
                json: data,
                responseType: "json"
            })
        ) as Promise<void>;
    }

    public async configJob(jobId: number, job: Partial<JobDefinition>): Promise<void> {
        const data = Object.fromEntries(Object.entries(job).filter(([key, value]) => key !== "schedules" && value !== undefined && value !== null));
        return got(
            `${this.requestUrl}/scheduler/jobs/${jobId}`,
            this.getRequestOptions("put", {
                json: data,
                responseType: "json"
            })
        ) as Promise<void>;
    }

    public async configJobByName(job: JobDefinition): Promise<void> {
        await got(`${this.requestUrl}/scheduler/jobs/${job.name}`, this.getRequestOptions("put", { json: job, responseType: "json" }));
    }

    public async configSchedule(jobId: number, scheduleId: number | string, schedule: Partial<ScheduleDefinition>): Promise<void> {
        return got(
            `${this.requestUrl}/scheduler/jobs/${jobId}/schedules/${scheduleId}`,
            this.getRequestOptions("put", {
                json: schedule,
                responseType: "json"
            })
        ) as Promise<void>;
    }

    public async createSchedule(jobId: number, schedule: Partial<ScheduleDefinition>): Promise<void> {
        return got(
            `${this.requestUrl}/scheduler/jobs/${jobId}/schedules`,
            this.getRequestOptions("post", {
                json: schedule,
                responseType: "json"
            })
        ) as Promise<void>;
    }
    public async getJobs(opts?: { page_size?: number; offset?: number; filter?: string; tenantId?: string }): Promise<JobDefinition[]> {
        const url = Object.entries(opts ?? {}).reduce((acc, [key, value], ix) => {
            const sep = ix === 0 ? "?" : "&";
            return `${acc}${sep}${key}=${value}`;
        }, `${this.requestUrl}/scheduler/jobs`);

        const response = await got(url, this.getRequestOptions("get", { responseType: "json" }));
        return (response as any).results;
    }
}
