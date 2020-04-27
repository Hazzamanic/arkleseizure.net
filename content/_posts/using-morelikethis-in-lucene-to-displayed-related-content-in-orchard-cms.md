---
title: Using MoreLikeThis in Lucene to displayed related content in Orchard CMS
tags:
- lucene
- MoreLikeThis
- Orchard
date: 2017-09-08
---
Lucene has an awesome class for finding related content called MoreLikeThis. It is what powers the Related section on Stack Overflow, and many more sites I'm sure. Aaron Johnson has an excellent overview of how it works on his [blog][1]. It is a bit wordy but well worth a read. Lucene.NET is a port of Lucene for .NET and (generally) examples written for Lucene (java) work just fine when converted to .NET. 

So here's the code to find related content. You'll need to grab the [Lucene.Contrib][2] package from nuget too. 

    using System;
    using System.Collections.Generic;
    using System.IO;
    using System.Linq;
    using Lucene.Models;
    using Lucene.Net.Index;
    using Lucene.Net.Search;
    using Lucene.Net.Search.Similar;
    using Lucene.Net.Store;
    using Orchard;
    using Orchard.Environment.Configuration;
    using Orchard.FileSystems.AppData;
    using Orchard.Indexing;
    using Directory = Lucene.Net.Store.Directory;
    using Lucene.Net.Analysis;
    using Lucene.Services;
    using System.Globalization;
    
    namespace NamespacesFtw {
        public interface IRelatedService : IDependency {
            IEnumerable<ISearchHit> GetRelatedItems(int id);
            IEnumerable<ISearchHit> GetRelatedItems(int id, RelatedContentContext context);
        }
    
        public class RelatedService : IRelatedService {
            private readonly IAppDataFolder _appDataFolder;
            private readonly string _basePath;
            private readonly IIndexManager _indexManager;
            private readonly ILuceneAnalyzerProvider _analyzerProvider;
    
            public RelatedService(IAppDataFolder appDataFolder, ShellSettings shellSettings, IIndexManager indexManager, ILuceneAnalyzerProvider analyzerProvider) {
                _appDataFolder = appDataFolder;
                _indexManager = indexManager;
                _analyzerProvider = analyzerProvider;
                _basePath = _appDataFolder.Combine("Sites", shellSettings.Name, "Indexes");
            }
    
            private ISearchBuilder Search(string index) {
                return _indexManager.HasIndexProvider()
                    ? _indexManager.GetSearchIndexProvider().CreateSearchBuilder(index)
                    : new NullSearchBuilder();
            }
    
            public IEnumerable<ISearchHit> GetRelatedItems(int id, RelatedContentContext context) {
                IndexReader reader = IndexReader.Open(GetDirectory(context.Index), true);
                var indexSearcher = new IndexSearcher(reader);
                var analyzer = _analyzerProvider.GetAnalyzer(context.Index);
    
                var mlt = new MoreLikeThis(reader) {Boost = true, MinTermFreq = 1, Analyzer = analyzer, MinDocFreq = 1};
                if (context.FieldNames.Length > 0) {
                    mlt.SetFieldNames(context.FieldNames);
                }
    
                var docid = GetDocumentId(id, indexSearcher);
                Filter filter;
    
                BooleanQuery query = (BooleanQuery) mlt.Like(docid);
    
                if (!String.IsNullOrWhiteSpace(context.ContentType)) {
                    var contentTypeQuery = new TermQuery(new Term("type", context.ContentType));
                    query.Add(new BooleanClause(contentTypeQuery, Occur.MUST));
                }
    
                // exclude same doc
                var exclude = new TermQuery(new Term("id", id.ToString()));
                query.Add(new BooleanClause(exclude, Occur.MUST_NOT));
    
                TopDocs simDocs = indexSearcher.Search(query, context.Count);
                var results = simDocs.ScoreDocs
                    .Select(scoreDoc => new LuceneSearchHit(indexSearcher.Doc(scoreDoc.Doc), scoreDoc.Score));
    
                return results;
            }
    
            protected virtual Directory GetDirectory(string indexName) {
                var directoryInfo = new DirectoryInfo(_appDataFolder.MapPath(_appDataFolder.Combine(_basePath, indexName)));
                return FSDirectory.Open(directoryInfo);
            }
    
            public int GetDocumentId(int contentItemId, IndexSearcher searcher) {
                var query = new TermQuery(new Term("id", contentItemId.ToString(CultureInfo.InvariantCulture)));
                var hits = searcher.Search(query, 1);
                return hits.ScoreDocs.Length > 0 ? hits.ScoreDocs[0].Doc : 0;
            }
    
            public IEnumerable<ISearchHit> GetRelatedItems(int id) {
                return GetRelatedItems(id, new RelatedContentContext());
            }
        }
    }

I've included all the usings because I like to copy + paste from other blogs, not mess with usings! Oh and here is some lame class I created for handling the configuration stuffs...

    public class RelatedContentContext {
        public string[] FieldNames { get; set; } = new string[] { "title", "body", "tags" };
        public string ContentType { get; set; }
        public int Count { get; set; } = 5;
        public string Index { get; set; } = "search";
    }

No usings for you here.

Naturally, I ran into a few issues. It appears that by default Lucene.NET does not use all fields if no fields are specified, but it actually just uses the "contents" field. Which I didn't have. It also requires the MinTermFreq and MinDocFreq to be set explicitly even though they have defaults. Another issue is that MoreLikeThis needs Term Vectors. Well, it can build them on the fly, but then it requires the fields to be stored in the index. Unfortunately, Orchard neither stores (it does have the option in the api to set a indexed field to be stored but very few actually are set) or builds the term vectors. To get around this I have overridden the default Lucene implementation with my own that simply adds the term vectors in. 

    using System;
    using System.Collections.Generic;
    using System.Linq;
    using System.Web;
    using Lucene.Net.Documents;
    using Lucene.Net.Index;
    using Lucene.Services;
    using Orchard;
    using Orchard.Environment.Configuration;
    using Orchard.Environment.Extensions;
    using Orchard.FileSystems.AppData;
    using Orchard.Indexing;
    using Orchard.Logging;
    
    namespace NamespacesFtw {
        [OrchardSuppressDependency("Lucene.Services.LuceneIndexProvider")]
        public class LuceneIndexProvider : Lucene.Services.LuceneIndexProvider, IIndexProvider {
            private readonly ILuceneAnalyzerProvider _analyzerProvider;
            public LuceneIndexProvider(IAppDataFolder appDataFolder, ShellSettings shellSettings, ILuceneAnalyzerProvider analyzerProvider) 
                : base(appDataFolder, shellSettings, analyzerProvider) {
                _analyzerProvider = analyzerProvider;
            }
    
            public new void Store(string indexName, IDocumentIndex indexDocument) {
                Store(indexName, new[] { (LuceneDocumentIndexTermVector)indexDocument });
            }
    
            public new void Store(string indexName, IEnumerable<IDocumentIndex> indexDocuments) {
                Store(indexName, indexDocuments.Cast<LuceneDocumentIndexTermVector>());
            }
    
            public void Store(string indexName, IEnumerable<LuceneDocumentIndexTermVector> indexDocuments) {
                indexDocuments = indexDocuments.ToArray();
    
                if (!indexDocuments.Any()) {
                    return;
                }
    
                // Remove any previous document for these content items
                Delete(indexName, indexDocuments.Select(i => i.ContentItemId));
    
                using (var writer = new IndexWriter(GetDirectory(indexName), _analyzerProvider.GetAnalyzer(indexName), false, IndexWriter.MaxFieldLength.UNLIMITED)) {
                    foreach (var indexDocument in indexDocuments) {
                        var doc = CreateDocument(indexDocument);
    
                        writer.AddDocument(doc);
                        Logger.Debug("Document [{0}] indexed", indexDocument.ContentItemId);
                    }
                }
            }
    
            public new IDocumentIndex New(int documentId) {
                return new LuceneDocumentIndexTermVector(documentId, T);
            }
    
            private static Document CreateDocument(LuceneDocumentIndexTermVector indexDocument) {
                var doc = new Document();
    
                indexDocument.PrepareForIndexing();
                foreach (var field in indexDocument.Fields) {
                    doc.Add(field);
                }
                return doc;
            }
        }
    
        [OrchardSuppressDependency("Lucene.Models.LuceneDocumentIndex")]
        public class LuceneDocumentIndexTermVector : IDocumentIndex {
    
            public List<AbstractField> Fields { get; private set; }
    
            private string _name;
            private string  _stringValue;
            private int _intValue;
            private double _doubleValue;
            private bool _analyze;
            private bool _store;
            private bool _removeTags;
            private TypeCode _typeCode;
    
            public int ContentItemId { get; private set; }
    
            public LuceneDocumentIndexTermVector(int documentId, Localizer t) {
                Fields = new List<AbstractField>();
                SetContentItemId(documentId);
                IsDirty = false;
                
                _typeCode = TypeCode.Empty;
                T = t;
            }
    
            public Localizer T { get; set; }
    
            public bool IsDirty { get; private set; }
    
            public IDocumentIndex Add(string name, string value) {
                PrepareForIndexing();
                _name = name;
                _stringValue = value;
                _typeCode = TypeCode.String;
                IsDirty = true;
                return this;
            }
    
            public IDocumentIndex Add(string name, DateTime value) {
                return Add(name, DateTools.DateToString(value, DateTools.Resolution.MILLISECOND));
            }
    
            public IDocumentIndex Add(string name, int value) {
                PrepareForIndexing();
                _name = name;
                _intValue = value;
                _typeCode = TypeCode.Int32;
                IsDirty = true;
                return this;
            }
    
            public IDocumentIndex Add(string name, bool value) {
                return Add(name, value ? 1 : 0);
            }
    
            public IDocumentIndex Add(string name, double value) {
                PrepareForIndexing();
                _name = name;
                _doubleValue = value;
                _typeCode = TypeCode.Single;
                IsDirty = true;
                return this;
            }
    
            public IDocumentIndex Add(string name, object value) {
                return Add(name, value.ToString());
            }
    
            public IDocumentIndex RemoveTags() {
                _removeTags = true;
                return this;
            }
    
            public IDocumentIndex Store() {
                _store = true;
                return this;
            }
    
            public IDocumentIndex Analyze() {
                _analyze = true;
                return this;
            }
    
            public IDocumentIndex SetContentItemId(int contentItemId) {
                ContentItemId = contentItemId;
                Fields.Add(new Field("id", contentItemId.ToString(), Field.Store.YES, Field.Index.NOT_ANALYZED));
                return this;
            }
    
            public void PrepareForIndexing() {
                switch(_typeCode) {
                    case TypeCode.String:
                        if(_removeTags) {
                            _stringValue = _stringValue.RemoveTags(true);
                        }
                        var f = new Field(_name, _stringValue ?? String.Empty,
                            _store ? Field.Store.YES : Field.Store.NO,
                            _analyze ? Field.Index.ANALYZED : Field.Index.NOT_ANALYZED, Field.TermVector.YES);
                        Fields.Add(f);
                        break;
                    case TypeCode.Int32:
                        var nf = new NumericField(_name,
                            _store ? Field.Store.YES : Field.Store.NO,
                            true).SetIntValue(_intValue);
                        Fields.Add(nf);
                        break;
                    case TypeCode.Single:
                        Fields.Add(new NumericField(_name,
                            _store ? Field.Store.YES : Field.Store.NO,
                            true).SetDoubleValue(_doubleValue));
                        break;
                    case TypeCode.Empty:
                        break;
                    default:
                        throw new OrchardException(T("Unexpected index type"));
                }
    
                _removeTags = false;
                _analyze = false;
                _store = false;
                _typeCode = TypeCode.Empty;
            }
        }
    }

So now we have a bunch of ISearchHits which we can use to get our content items.

    var related = _relatedSerive.GetRelatedItems(contentItem.Id, context);
    var contentItems = _contentManger.GetMany<IContent>(related.Select(e => e.ContentItemId), VersionOptions.Published, QueryHints.Empty);

Then just display them however you please!

I am currently developing the module with extra settings etc. so that it's a little more usable in the real world.

**Update (07/09/2017):** I didn't really develop the module much more but I the code is now on [GitHub][3] anyway and you can see it working on my [travel blog][4].


  [1]: http://cephas.net/blog/2008/03/30/how-morelikethis-works-in-lucene/
  [2]: https://www.nuget.org/packages/Lucene.Net.Contrib/3.0.3
  [3]: https://github.com/Hazzamanic/Hazza.RelatedContent
  [4]: http://travellingwrong.com/