# Artifact Validation

This document records the validation performed on the supplied benchmark files. Validation is based on the text present in the archived output; the executables were not available for rerunning in this workspace.

## NPB MPI

Each complete output should contain successful verification for EP, CG, FT, MG, IS, BT, SP, and LU. At 128 ranks, the submitted script intentionally omits BT and SP because 128 is not a square process count.

| Class | MPI ranks | Observed status |
|---|---:|---|
| S | 1, 4 | Complete; 8 successful verifications per file |
| A | 1, 4, 16, 64 | Complete; 8 successful verifications per file |
| A | 128 | Complete as scripted; 6 successful verifications, with BT and SP skipped |
| A | 256 | Partial; CG has no completed result, while 7 programs verified |
| B | 1, 4, 16, 64, 256 | Complete; 8 successful verifications per file |
| B | 128 | Complete as scripted; 6 successful verifications, with BT and SP skipped |
| C | 1, 4, 16, 64 | Complete; 8 successful verifications per file |
| C | 128 | Complete as scripted; 6 successful verifications, with BT and SP skipped |
| C | 256 | Partial; MG has no completed result, while 7 programs verified |

## NPB OpenMP

| Class | Threads | Observed status |
|---|---:|---|
| S | 1, 4, 16, 64, 128 | Complete; 8 successful verifications per file |
| A | 1, 4, 16, 64, 128 | Complete; 8 successful verifications per file |
| B | 1, 4, 16, 64, 128 | Complete; 8 successful verifications per file |
| C | 4, 16, 64, 128 | Complete; 8 successful verifications per file |
| C | 1 | Partial across two attempts; EP, CG, IS, BT, SP, and LU completed, but FT and MG did not |

The two Class C, one-thread files are both preserved because they show separate attempts:

- `ompC-1t.480242.out`
- `ompC-1t.480297.out`

## LULESH OpenMP

All strong- and weak-scaling OpenMP files contain:

- one completed LULESH run;
- the expected OpenMP thread count;
- 100 iterations;
- final energy-difference checks;
- elapsed time and FOM output.

No completion failure was found in these ten files.

## LULESH MPI

The requested rank counts were 1, 8, 27, 64, 125, and 216 for both strong and weak scaling. The multi-rank files instead show repeated independent serial executions:

| Requested ranks | `Run completed` blocks in each file | LULESH-reported MPI tasks |
|---:|---:|---:|
| 1 | 1 | 1 |
| 8 | 8 | 1 in every block |
| 27 | 27 | 1 in every block |
| 64 | 64 | 1 in every block |
| 125 | 125 | 1 in every block |
| 216 | 216 | 1 in every block |

Therefore, only the one-rank file represents the intended execution shape. The other files are invalid for MPI scaling analysis.

Recommended correction:

1. Configure a fresh LULESH build with MPI support enabled.
2. Confirm that the executable links against MPI.
3. Run a small two- or eight-rank test.
4. Confirm that LULESH reports the requested MPI task count once, rather than printing one serial result per task.
5. Only then repeat the full strong- and weak-scaling matrix.

## IO500

### Debug run

The 4-rank debug run completed with a 1-second stonewall. It is a functional test, not a performance result.

### 1-rank and 4-rank runs

Both runs completed and produced detailed result files. IO500 explicitly marked the results invalid for these reasons:

- `stonewall-time 30s != 300s`;
- several write phases ran for less than the expected minimum duration;
- the `find` phase did not find matching files.

The total scores must therefore be reported with the `[INVALID]` label.

### 8-rank run

The 8-rank run is incomplete. Slurm reported:

```text
prterun noticed that process rank 6 ... exited on signal 9 (Killed).
slurmstepd: error: Detected 1 oom_kill event ...
```

Only the early write-phase artifacts exist. `result_summary.txt` is empty and no total score was produced.

### Configuration note

`io500-debug-510116.ini` is an earlier template containing placeholder Lustre paths. No matching result directory for job 510116 was supplied.

## Sensitive-data scan

No passwords, access tokens, API keys, or private keys were found. The raw files do include expected cluster identifiers such as the username, job IDs, node names, Slurm account, and filesystem paths.
