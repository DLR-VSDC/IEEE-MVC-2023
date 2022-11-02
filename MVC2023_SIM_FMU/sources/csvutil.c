/* csvutil.c
 *
 * Utility functions for reading simple CSV files ("comma separated values").
 * The declarations follow the Modelica specification for external functions.
 *
 * Copyright (c) 2004 Dynasim AB.
 * All rights reserved.
 */

#ifndef CSVUTIL_C
#define CSVUTIL_C

#include "csvutil.h"
#include <ctype.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#if defined(OPENGL)
#include "supportunicodefiles.h"
#endif
#include "ModelicaUtilities.h"
#include "localeless.h"

/* char line [line_len] */
static char* ReadLine(FILE* f, char line[], size_t line_len)
{
    line[0] = '\0';

    if (fgets(line, (int)line_len, f) == NULL)
        line[0] = '\0';
	/* fgets adds at most line_len-1 characters from file, and always end with NUL */
    return line;
}

static int LineEmpty(const char* line)
{
    if (line == 0) return 0;
    return strlen(line) == 0 || (strlen(line)==1 && line[0]=='\n');
}

static int IsLegendRow(const char* line)
/* Returns true if line contains any character not expected in a data row. */
{
    const char* datachar = "0123456789+-eE.,;\t\r\n ";
    if (line == 0) return 0;
    while (*line != '\0') {
        if (strchr(datachar, *line) == NULL) return 1;
        line++;
    }
    return 0;
}
static void HandleLongLine(char*line, size_t shortBuf, size_t fullBuf, FILE*f) {
	size_t i;
	size_t copySize=fullBuf-shortBuf-1;
	for(i=0;i<copySize;++i) line[i]=line[i+shortBuf]; /* Ignoring NUL */
	if (!strchr(line+shortBuf,'\n')) ReadLine(f, line+copySize, fullBuf-copySize);
}
static int GetColumns(char* line, const char* separators, FILE*f, size_t bufLen)
{
    int cols = 0;
	int hasNL = 0;
	char* origLine=line;
    if (!LineEmpty(line)) {
        cols = 1;
        while (*line != '\0') {
            if (*line == separators[0]) cols ++;
			if (*line == '\n') hasNL=1;
            line++;
        }
    }
	if (!hasNL) {
		ReadLine(f, origLine, bufLen);
		return cols+GetColumns(origLine, separators, f, bufLen);
	}
    return cols;
}

static const char* FieldSeparator(const char* line, char sep[20])
/* Use some heuristic to determine what field separator has been used. */
{
    strcpy(sep, "  \t\r\n");
    /* First character is the separator we think is valid, the remaining
       are used to skip optional whitespace. */

	if (*line=='\"') {
		/* Quoted */
		const char*nextQuote=strchr(line+1,'\"');
		if (nextQuote && nextQuote[1]) {
			sep[0]=nextQuote[1];
			return sep;
		}
	}
	if (strchr(line, ';') != NULL)
        sep[0] = ';';
    else if (strchr(line, '\t') != NULL)
        sep[0] = '\t';
    else
        sep[0] = ',';
    return sep;
}


/* readCSVsizes() - read sizes from a CSV text file */

void readCSVsizes(const char* filename /* File containing the data */,
                  int* sizes /* Returns number of rows, columns, row legends, column legends */,
                  size_t sizes_dim1)
{
    FILE* f;
    char* line;
    int column_legends_exist = 0;
	char line_buffer[50001];
	size_t buffer_len=sizeof(line_buffer);
	char sep_buffer[20];

    if (!filename || sizes_dim1!=4) return; /* Should use assertions */
    
#define sizes_rows sizes[0]
#define sizes_column sizes[1]
#define sizes_row_legends sizes[2] /* Not supported */
#define sizes_column_legends sizes[3]
    
    sizes_rows = sizes_column = sizes_row_legends = sizes_column_legends = 0;
    
    f = fopen(filename, "r");
    if (f == NULL) return;
    
    /* Read first line and skip rows with column legends. After this part line contains data. */
    
    line = ReadLine(f, line_buffer, buffer_len);
    while (IsLegendRow(line)) {
		while (!strchr(line,'\n') && strlen(line) == buffer_len-1 && !LineEmpty(line)) {
			/* Read until end of line */
			line = ReadLine(f, line_buffer, buffer_len);
		}
        column_legends_exist = 1;
        line = ReadLine(f, line_buffer, buffer_len);
    }
    
    /* Determine field separator and number of columns from first data line. */
    /* Then count remaining lines. */
    
    if (!LineEmpty(line)) {
        const char* sep = FieldSeparator(line, sep_buffer);
        
        sizes_column = GetColumns(line, sep, f, buffer_len);
        if (column_legends_exist) sizes_column_legends = sizes_column;
        do {
            sizes_rows++;
            line = ReadLine(f, line_buffer, buffer_len);
			while (!strchr(line,'\n') && strlen(line) == buffer_len-1 && !LineEmpty(line)) {
				/* Read until end of line */
				line = ReadLine(f, line_buffer, buffer_len);
			}
        } while (!LineEmpty(line));
    }
    fclose(f);
}

/* readCSVdata() - read data from a text file with comma separated values */

static char* skipLeadingSeparators(char*line, const char*sep) {
	for(;*line && strchr(sep,*line);)
		++line; /* Skip first character if separator */
	if (*line) return line;
	return 0;
}

void readCSVmatrixInternal2(const char* filename /* File containing the data */,
                         int n_rows /* Number of rows */,
                         int n_columns /* Number of columns */,
                         double* data /* Read data, size n_rows*n_columns */,
                         size_t data_dim1,
                         size_t data_dim2,
						 int hasTimedOut)
{
    const int sz = n_rows*n_columns;
    FILE* f;
    char* line;
    int i;
	char line_buffer[50001];
	size_t buffer_len=sizeof(line_buffer);
	char sep_buffer[20];

	if (!filename || !data) return; /* Should use assertions */

    for (i = 0; i < sz; i++) data[i] = 0;

    f = fopen(filename, "r");
	if (f == NULL) {
		if (!hasTimedOut)
			ModelicaFormatError("Cannot open file \"%s\".",filename);
		return;
	}
    
    /* Read first line and skip legend rows. After this part line contains data. */
    
    line = ReadLine(f, line_buffer, buffer_len);
    while (IsLegendRow(line)) {
		while (!strchr(line,'\n') && strlen(line) == buffer_len-1 && !LineEmpty(line)) {
			/* Read until end of line */
			line = ReadLine(f, line_buffer, buffer_len);
		}
        line = ReadLine(f, line_buffer, buffer_len);
    }
    
    /* Determine field separator and and read data lines. */
    
    if (!LineEmpty(line)) {
        const char* sep = FieldSeparator(line, sep_buffer);
        
        i = 0;
        do {
			char * tok = skipLeadingSeparators(line, sep);
			int hasLongLine=strchr(line,'\n')==0;
			for(;tok;) {
				if (hasLongLine && tok>=line+buffer_len/2) {
					HandleLongLine(line, buffer_len/2, buffer_len, f);
					tok-=(buffer_len/2);
				}
				{
					char * next = strpbrk(tok, sep);
					char * comma;
					char dummy;
					if (next!=0) 
						*next=0;
					comma=strchr(tok,',');
					if (comma!=0) *comma='.'; /* Convert decimal comma to decimal dot */
					if (i < sz) {
						if (sscanfClfc(tok,data+i,&dummy)!=1) {
							fclose(f);
							ModelicaFormatError("Could not parse file \"%s\": element (%d, %d)=\"%s\".",
								filename,1+(i/n_columns),1+(i%n_columns),tok);
							return;
						}
					}
					i++;
					if (next==0) break; /* Ok. Just no trailing separator */
					tok = skipLeadingSeparators(next+1, sep);
				}
            }
            line = ReadLine(f, line_buffer, sizeof(line_buffer));
        } while (!LineEmpty(line));
		if (i!=sz) {
			fclose(f);
			if (!hasTimedOut)
				ModelicaFormatError("Incorrect data-length for file \"%s\" should be %d * %d=%d, but was %d.",
					filename, n_rows, n_columns, sz, i);
			return;
		}
    }
    fclose(f);
}
void readCSVmatrixInternal(const char* filename /* File containing the data */,
							int n_rows /* Number of rows */,
							int n_columns /* Number of columns */,
							double* data /* Read data, size n_rows*n_columns */,
							size_t data_dim1,
							size_t data_dim2)
{
	readCSVmatrixInternal2(filename,
		n_rows,
		n_columns,
		data,
		data_dim1,
		data_dim2,
		0);
}
void readCSVHeadersInternal(const char* filename /* File containing the data */,
                         int n_columns /* Number of columns */,
						 const char** data, const char*StringAlloc(const char*)) 
{
    FILE* f;
    char* line;
    int i;
	int hasHeading=0;
	char sep_buffer[20];
	char line_buffer[50001];
	size_t buffer_len=sizeof(line_buffer);
	int hasLongLine=0;
        
	if (!filename || !data) return; /* Should use assertions */

    f = fopen(filename, "r");
    if (f == NULL) return;
    
    /* Read first line and skip legend rows. After this part line contains data. */
    
    line = ReadLine(f, line_buffer, buffer_len);
    while (IsLegendRow(line)) {
		while (!strchr(line,'\n') && strlen(line) == buffer_len-1 && !LineEmpty(line)) {
			/* Read until end of line */
			line = ReadLine(f, line_buffer, buffer_len);
		}
        line = ReadLine(f, line_buffer, buffer_len);
		hasHeading=1;
    }
    
    /* Determine field separator and and read data lines. */
    
    if (!LineEmpty(line) && hasHeading) {
        const char* sep = FieldSeparator(line, sep_buffer);
		int hasLongLine;
		const char*res;
		/*Re-read heading: */
		fseek(f, SEEK_SET, 0);
		line = ReadLine(f, line_buffer, buffer_len);
		hasLongLine=line && strchr(line,'\n')==0;
		if (line && line[0]=='\"') {	
			char*tok=line;
			char*tok2;
			for(i=0;i<n_columns;++i) {
				if (hasLongLine && tok>=line+buffer_len/2) {
					HandleLongLine(line, buffer_len/2, buffer_len, f);
					tok-=(buffer_len/2);
				}
				while(tok[0]==' ')++tok;/*Skip whitespaces*/
				if (tok[0]!='\"' || tok[1]=='\0') break;
				tok2=strchr(tok+2,'\"');/*Find end quoute*/
				if (!tok2) break;
				*tok2++='\0';/* Remove quote end string*/
				res=StringAlloc(tok+1);
				if (res) data[i]=res;
				tok=strchr(tok2,sep[0]); /*Skip eventual whitespaces before sep*/
				if(!tok)break;
				++tok;/* Skip separator */
			}
		} else if (line) {
			char * tok = skipLeadingSeparators(line, sep);
			for(i=0;tok && i<n_columns;) {
				if (hasLongLine && tok>=line+buffer_len/2) {
					HandleLongLine(line, buffer_len/2, buffer_len, f);
					tok-=(buffer_len/2);
				}
				{
					char * next = strpbrk(tok, sep);
					if (next!=0) 
						*next=0;
					res=StringAlloc(tok);
					if (res) data[i] = res;
					i++;
					if (next==0) break; /* Ok. Just no trailing separator */
					tok = skipLeadingSeparators(next+1, sep);
				}
            }
		}
	}
	fclose(f);
}

int WriteCSVmatrixInternal(const char*fname, double*values, size_t rows, size_t columns, 
						   const char*const*headers, const char*separator, int addQuote) {
	int ok=0;
	size_t i,j;
	FILE*f=fopen(fname, "w");
	if (f) {
		ok=1;
		if (headers) {
			const char*aroundHeader="";
			if(!addQuote){
				for(j=0;j<columns;++j) {
					const char*ch;
					for(ch=headers[j];*ch;++ch) 
						addQuote=addQuote || strchr("\t;, ",*ch);
				}
			}
			if (addQuote) aroundHeader="\"";
			for(j=0;j<columns;++j) {
				if (j!=0)
					fprintfC(f, "%s", separator);
				fprintfC(f, "%s%s%s", aroundHeader, headers[j], aroundHeader);
			}
			fprintfC(f, "\n");
		}
		for(i=0;i<rows;++i) {
			for(j=0;j<columns;++j) {
				if (j!=0)
					fprintfC(f, "%s", separator);
				fprintfC(f, "%.17g", values[i*columns+j]);
			}
			fprintfC(f, "\n");
		}
		ok = ok && !ferror(f);
		fclose(f);
	}
	return ok;
}

#if !defined(DYMOLAB) && !defined(OPENGL)
#include <matrixop.h>
IntegerArray readCSVsizes_M(const char*f) {
	IntegerArray t=IntegerTemporaryVector(4);
	readCSVsizes(f, t.data, 4);
	return t;
};
RealArray readCSVmatrixInternal_M(const char*f, int r, int c) {
	RealArray t=RealTemporaryMatrix(r,c);
	readCSVmatrixInternal(f, r, c, t.data, r, c);
	return t;
};
int writeCSVFileInternal_M(const char*f, StringArray headers, RealArray data, const char*sep, int quoteAll) {
	return WriteCSVmatrixInternal(f, data.data, data.dims[0], data.dims[1], headers.data, sep, quoteAll);
}

static const char*readCSVAllocate(const char*t) {
	char*s2=ModelicaAllocateStringWithErrorReturn(strlen(t));
	if (s2) strcpy(s2, t);
	return s2;
}
StringArray readCSVHeadersInternal_M(const char*f) {
	int sizes[4];
	readCSVsizes(f, sizes, 4);
	{
		int i;
		const char*emptyString="";
		StringArray t=StringFillAssign(StringTemporaryVector(sizes[1]), emptyString);
		readCSVHeadersInternal(f, t.dims[0], t.data, readCSVAllocate);
		for(i=0;i<t.dims[0];++i) if (t.data[i]==emptyString) ModelicaFormatError("Could not allocate heading for  file \"%s\": element (%d)=",f,i+1);
		return t;
	}
}
#endif
#endif
