
#ifndef BSPATCH_H
# define BSPATCH_H

# include <stdint.h>

struct bspatch_stream
{
    void* opaque;
    int (*read)(const struct bspatch_stream* stream, void* buffer, int length);
};

int bspatch(const uint8_t* old, int64_t oldsize, uint8_t* newBuf, int64_t newsize, struct bspatch_stream* stream);
int beginPatch(const char* oldfile, const char* newfile, const char* patchfile);

int startPatch(const char* oldfile, const char* newfile, const char* patchfile);

#endif
